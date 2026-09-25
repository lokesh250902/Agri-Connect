import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/voice_button.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService(); final audio = AudioService(); final player = AudioPlayer(); final picker = ImagePicker();
  final messages = <ChatMessage>[]; bool recording=false, busy=false; String language='English';
  @override void dispose(){ audio.dispose(); player.dispose(); super.dispose(); }

  // Only native platforms need a real filesystem path for the recorder to
  // write to; the record package ignores this on web and records to a Blob.
  Future<String> recordingPath() async => kIsWeb ? 'voice_input.wav' : '${(await getTemporaryDirectory()).path}/voice_input.wav';
  Future<void> toggleRecord() async { if(busy)return; if(recording){ await stopRecord(); } else { await startRecord(); } }
  Future<void> startRecord() async { try { await audio.start(await recordingPath()); setState(()=>recording=true); } catch(e){ error(e); } }
  Future<void> stopRecord() async { try { final b=await audio.stop(); setState(()=>recording=false); if(b!=null) await processVoice(b); } catch(e){setState(()=>recording=false); error(e);} }
  Future<void> processVoice(Uint8List audioBytes) async { setState(()=>busy=true); try { final r=await api.sendVoice(audioBytes); language=r['language']??language; setState(() { messages.add(ChatMessage(text:r['transcript']??'',type:MessageType.user,language:language)); messages.add(ChatMessage(text:r['answer']??'',type:MessageType.assistant,language:language)); }); await play(api.audioBytes(r)); } catch(e){error(e);} finally{if(mounted)setState(()=>busy=false);} }
  Future<void> pickImage() async { final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:85); if(x==null)return; setState(()=>busy=true); try { final bytes=await x.readAsBytes(); final r=await api.sendImage(bytes,language,filename:x.name,contentType:x.mimeType??_imageMimeFromName(x.name)); setState(()=>messages.add(ChatMessage(text:r['answer']??'',type:MessageType.assistant,language:language))); await play(api.audioBytes(r)); } catch(e){error(e);} finally{if(mounted)setState(()=>busy=false);} }
  // image_picker's XFile.mimeType is often null on some platforms; fall back to guessing from the filename extension.
  String _imageMimeFromName(String name) { final n=name.toLowerCase(); if(n.endsWith('.png')) return 'image/png'; if(n.endsWith('.webp')) return 'image/webp'; if(n.endsWith('.heic')) return 'image/heic'; if(n.endsWith('.heif')) return 'image/heif'; return 'image/jpeg'; }
  Future<void> showWeather() async { try { var p=await _position(); final w=await api.weather(p.latitude,p.longitude); final c=w['current']; final text='Current weather: ${c['temperature_2m']}°C, humidity ${c['relative_humidity_2m']}%. Forecast data is available for the next 7 days.'; setState(()=>messages.add(ChatMessage(text:text,type:MessageType.assistant,language:'English'))); } catch(e){error(e);} }
  Future<Position> _position() async { if(!await Geolocator.isLocationServiceEnabled()) throw Exception('Please enable Location/GPS.'); var perm=await Geolocator.checkPermission(); if(perm==LocationPermission.denied) perm=await Geolocator.requestPermission(); if(perm==LocationPermission.denied || perm==LocationPermission.deniedForever) throw Exception('Location permission is required for weather.'); return Geolocator.getCurrentPosition(); }
  Future<void> play(Uint8List b) async { await player.stop(); await player.play(BytesSource(b,mimeType:'audio/wav')); }
  void error(Object e){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Agri Voice AI'),actions:[IconButton(onPressed:pickImage,icon:const Icon(Icons.photo_camera_outlined)),IconButton(onPressed:showWeather,icon:const Icon(Icons.cloud_outlined))]),body:Column(children:[Expanded(child:messages.isEmpty?_welcome():ListView(children:messages.map((m)=>ChatBubble(message:m)).toList())),if(busy)const Padding(padding:EdgeInsets.all(8),child:CircularProgressIndicator()),Padding(padding:const EdgeInsets.fromLTRB(20,10,20,30),child:Column(children:[Text(recording?'Listening...':busy?'Processing...':'Speak or upload a crop image'),const SizedBox(height:14),VoiceButton(recording:recording,onTap:toggleRecord)]))]));
  Widget _welcome()=>const Center(child:Padding(padding:EdgeInsets.all(30),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.agriculture,size:90,color:Colors.green),SizedBox(height:20),Text('Agri Voice AI',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),SizedBox(height:12),Text('Ask about weather, crops, farming or upload a plant image.',textAlign:TextAlign.center,style:TextStyle(fontSize:16))])));
}
