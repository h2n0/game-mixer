module flssnd.soundsystem;

import std.stdio;
import std.format:format;
import std.string:toStringz; 
import std.conv:to;
import gamemixer;
import std.file:exists;


class SoundSystem {

    // References to the buffers that store the data
    protected IAudioSource[string] samples;
    protected IAudioSource[string] music;

    protected IAudioSource[][string] soundbanks;

    protected IMixer mixer;

    this(){
        MixerOptions options;
        this.mixer = mixerCreate(options);
    }

    ~this(){
        mixerDestroy(mixer);
    }

    bool loadSoundBank(string name, string[] paths){
        IAudioSource[] res;
        res.length = paths.length;

        for(int i = 0; i < paths.length; i++){
            string path = paths[i];
            if(exists(path)){
                res[i] = this.mixer.createSourceFromFile(path);
            }else{
                res = [];
                return false;
            }
        }
        soundbanks[name] = res;
        return true;
    }

    bool loadSample(string name, string path){
        if(exists(path)){
            this.samples[name] = this.mixer.createSourceFromFile(path);
            return true;
        }else{
            // printWarning("No sound file @ '" ~ path ~ "'");
            return false;
        }
    }

    bool loadMusic(string name, string path){
        if(exists(path)){
            this.music[name] = this.mixer.createSourceFromFile(path);
            return true;
        }else{
            // printWarning("No music file @ '" ~ path ~ "'");
            return false;
        }
    }

    void setMasterVolume(float vol){
        this.mixer.setMasterVolume(vol);
    }

    private IAudioSource getSample(string name){
        IAudioSource* res = name in samples;
        if(!res){
            // printWarning("Counldn't get sample '" ~ name ~ "'");
            return null;
        }else{
            return *res;
        }
    }

    private IAudioSource getMusic(string name){
        IAudioSource* res = name in music;
        if(!res){
            // printWarning("Counldn't get music '" ~ name ~ "'");
            return null;
        }else{
            return *res;
        }
    }

    void playSample(string name){
        IAudioSource res = getSample(name);
        if(res is null) return;

        this.mixer.play(res);
    }

    void playMusic(string name){
        IAudioSource res = getMusic(name);
        if(res is null) return;

        PlayOptions op;
        // op.loopCount = loopForever;
        op.channel = 0;
        this.mixer.play(res, op);
    }

    final bool isAnythingPlaying(){
        return this.mixer.isAnythingPlaying();
    }

    final bool isChannelFree(int channel){
        return this.mixer.isChannelFree(channel);
    }
}