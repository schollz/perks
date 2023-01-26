
(
s.waitForBoot({
	s.record;
	l.free;

	l=LorenzosDrums2.new(Server.default, thisProcess.nowExecutingPath.dirname++"/lorenzos-drums/");


	SynthDef("bigbass",{
		arg hz=220,amp=0.5,gate=1,sub=0,portamento=1,bend=0,
		attack=0.01,decay=0.2,sustain=0.9,release=5,
		mod1=0,mod2=0,mod3=0,mod4=0,lpf=18000,pan=0,duration=600;
		var snd,note,freq,oscfreq,env,envFilter,detune,distortion,lowcut,chorus,res;
		hz=Clip.kr(hz,10,18000);mod1=Lag.kr(mod1);mod2=Lag.kr(mod2);mod3=Lag.kr(mod3);mod4=Lag.kr(mod4);
		note=Lag.kr(hz,portamento).cpsmidi+bend;
		env=EnvGen.ar(Env.adsr(attack,decay,sustain,release),(gate-EnvGen.kr(Env.new([0,0,1],[duration,0]))),doneAction:2);
		env=env*EnvGen.ar(Env.new([1,0],[\gate_release.kr(1)]),Trig.kr(\gate_done.kr(0)),doneAction:2);
		sub=Lag.kr(sub,1);
		distortion=LinLin.kr(mod1,-1,1,1,20);
		lowcut=LinLin.kr(mod2,-1,1,1,16);
		res=LinLin.kr(mod3,-1,1,-4,8);
		detune=LinLin.kr(mod4,-1,1,-0.6,0.62);
		freq=note.midicps/2;

		oscfreq = {freq * LFNoise2.kr(0.5).range(1-detune, 1+detune)}!3;
		snd = Splay.ar(LFSaw.ar(oscfreq));
		envFilter = Env.adsr(attack/4, 4, 0, release).kr(gate: (gate-EnvGen.kr(Env.new([0,0,1],[duration,0]))));
		snd = (snd*distortion).tanh;
		snd=BLowShelf.ar(snd,freq,1,res);
		snd = LPF.ar(snd, (envFilter*freq*lowcut) + (2*freq));
		snd = (snd*envFilter).tanh;

		snd = Balance2.ar(snd[0],snd[1],Lag.kr(pan,0.1));
		snd = LPF.ar(snd,Lag.kr(lpf)) * env * amp / 2;
		Out.ar(0,snd);
	}).send(s);

	SynthDef("jp",{ | amp=1,freq = 523.3572, mix=0.75, detune = 0.75 |
		var detuneCurve = { |x|
			(10028.7312891634*x.pow(11)) -
			(50818.8652045924*x.pow(10)) +
			(111363.4808729368*x.pow(9)) -
			(138150.6761080548*x.pow(8)) +
			(106649.6679158292*x.pow(7)) -
			(53046.9642751875*x.pow(6)) +
			(17019.9518580080*x.pow(5)) -
			(3425.0836591318*x.pow(4)) +
			(404.2703938388*x.pow(3)) -
			(24.1878824391*x.pow(2)) +
			(0.6717417634*x) +
			0.0030115596
		};
		var centerGain = { |x| (-0.55366 * x) + 0.99785 };
		var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

		var center = LFSaw.ar(freq, Rand());
		var detuneFactor = freq * detuneCurve.(detune);
		var freqs = [
			(freq - (detuneFactor * 0.11002313)),
			(freq - (detuneFactor * 0.06288439)),
			(freq - (detuneFactor * 0.01952356)),
			// (freq + (detuneFactor * 0)),
			(freq + (detuneFactor * 0.01991221)),
			(freq + (detuneFactor * 0.06216538)),
			(freq + (detuneFactor * 0.10745242))
		];
		var side = Mix.fill(6, { |n|
			LFSaw.ar(freqs[n], Rand(0, 2))
		});


		var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));

		sig = HPF.ar(sig ! 2, freq);
		sig = MoogLadder.ar(sig,freq*Rand(10,20));
		Out.ar(0,sig/7*EnvGen.ar(Env.perc(0.01,1.5),doneAction:2)*amp);
	}).send(s);
	s.sync;

	SynthDef("final",{
		var snd=In.ar(0,2);
		var sndR = Fverb.ar(snd[0],snd[1],20,decay:60);
		snd=SelectX.ar(0.14,[snd,sndR]);
		snd=AnalogTape.ar(snd,0.9,0.9,0.7,2);
		ReplaceOut.ar(0,snd);
	}).send(s);
	s.sync;

	Synth.new("final",[],s,\addToTail);
	
	~fnexdash={
		arg exdash,beat;
		var result=[0,0]; // [hits, beats]
		var n=exdash.size;
		var i=beat.mod(n);
		var cur=exdash[i].asString;
		[exdash,beat,i,exdash[i]].postln;
		if (cur=="x",{
			result[0]=1;
			result[1]=1;
		},{
			if (cur.asInteger>0,{
				result[0]=cur.asInteger;
			});
		});
		if (result[0]>0,{
			var ok=true;
			result[1]=1;
			(n-i-1).do({ arg j;
				var k=j+i+1;
				if (ok,{
					if (exdash[k].asString=="+",{
					result[1]=result[1]+1;

					},{ok=false;});
				});
			});
		});

		result
	};

	~kick_riddim="x-x-x-x-x-x-----";
	~kick_riddim="x---x---x---x-2-";
	~kick_riddim="x-x-------xx----";
	~kick_riddim="x-x-------x-----";
	~kick_riddim="--xx------x-----";
	~kick_riddim="x---x---x--2x-xx";
	~kick_riddim="x-x-----x-x-----";
	~snar_riddim="----x--x-x--x--x";
	~snar_riddim="----x--x----x--x";
	~snar_riddim="----x--x-x----x-";
	~snar_riddim="----x--x----x--x";
	~snar_riddim="----x--x----x--2";
	~snar_riddim="-x--x--x-x----x-";
	~snar_riddim="----x--x----222xxx2xxxx2xx-x-x-x";
	~hiha_riddim="xoxoxxx-xxx-xxxx";
	~ride_riddim="xxx-x-x-x-x-x-x-";
	~hiha_riddim="-";
	~kick_riddim="x---";
	~snar_riddim="-";
	~hiha_riddim="xxx-xxx-xxx-xxxx-o--xx";
	~kick_riddim="x---";
	~hiha_riddim="8-o-x-x-x-x-xxxx-x332-";
	~snar_riddim="x48xxxxx332";
	~snar_riddim="x24xxxx42x-x-";
	~snar_riddim="----x--x-x--x--x";
	~ride_riddim="x-x-x---------x-";
	~kick_riddim="x---x---x--x--x-";
	~hiha_riddim="xx-xxxxx2x-";
	~hiha_riddim="xx-xxxxx2x-xx4";
	~hiha_riddim="xx-xxxxx2x-xx4x-x-x33";
	~ride_riddim="x-";
	~hiha_riddim="x";
	~kick_riddim="x-------x-x---x-";
	~ride_riddim="-";
	~hiha_riddim="-";
	~snar_riddim="----x---";
	~snar_riddim="-";
	~octave=[5,5];
	~octave=[1,1];
	~noteSkip=50000;

	// ~ride_riddim="x";
	Routine{
		var bpm=120;
		var tpb=60/bpm/4;
		var snar_vel=[1,1,0,1,1,0,1,0,1,1,1,1,1,1,1,1,0];
		var kick_vel=[1,0,1,1];
		var ride_vel=[1];
		var hiha_vel=[1,0,1,0,1,0,1,0,1,1,0,1,1,0,1,0];
		var slop=20; // +/- milliseconds
		var t = TempoClock(8*bpm/120);
		var scale=Scale.major;
		var syncs=[1,1,1,1,1,0.5,0.5,1];
		var bass=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		var octav=[12,24,24];
		var notes=[0,3,7,5,0,3,7,5,0,3,7,5,0,3,7,5];
		notes=notes++[0,2,7,5,0,2,7,5,0,2,7,5,0,2,7,5];
		notes=notes++[-1,1,7,5,-1,1,7,5,-1,1,7,5,-1,1,7,5];
		notes=notes++[0,2,8,4,0,2,8,4,0,2,8,4,0,2,8,4,7];
		bass=bass++[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
		bass=bass++[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,];
		bass=bass++[4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4];
		// var octav=[0,0,0,12,12,12,24,24];
		// var notes=[0,2,4,0,2,4,0,2,0,2,4,0,2,4,0,2];
		// notes=notes++[-1,2,4,-1,2,4,-1,2,-1,2,4,-1,2,4,-1,2];
		// notes=notes++[-2,0,4,-2,0,4,-2,2,-2,0,4,-2,0,4,-2,2];
		// notes=notes++[-2,0,3,-2,0,3,2,-2,0,3,-2,0,3,3,4,-1,5];
		// bass=bass++[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
		// bass=bass++[-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2];
		// bass=bass++[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];

		0.1.wait;

		l.setFxParam("sine_drive",0.3);
		l.setFxParam("drive",0.5);
		l.setFxParam("compress_curve_wet",0.0);
		l.setFxParam("compress_curve_drive",0.1);
		l.setFxParam("expand_curve_wet",0.5);
		l.setFxParam("expand_curve_drive",1);
		l.setMixSnare(0,0.6,0.1);
		l.setMixKick(0,0.2,0.7);
		t.schedAbs(0, { arg i, sec;
			var rate=1.5;
			var beat=i.mod(16);
			var kick=~fnexdash(~kick_riddim,i);//~kick_riddim[i.mod(~kick_riddim.size)].asString;
			var snar=~snar_riddim[i.mod(~snar_riddim.size)].asString;
			var hiha=~hiha_riddim[i.mod(~hiha_riddim.size)].asString;
			var ride=~ride_riddim[i.mod(~ride_riddim.size)].asString;
			var snarv=snar_vel[i.mod(snar_vel.size)]*50+10.rand+60;
			var kickv=kick_vel[i.mod(kick_vel.size)]*30+10.rand+30;
			var ridev=(ride_vel[i.mod(ride_vel.size)]*30)+(10.rand+80);
			var hihav=hiha_vel[i.mod(hiha_vel.size)]*40+10.rand+70;
			var note=notes[i.mod(notes.size)];
			var bassnote=bass[i.mod(bass.size)];
			note=scale[note.mod(scale.size)]+octav[i.mod(octav.size)]+40;
			if (~octave[0].rand==1,{
				note=note+12;
			});
			if (~octave[1].rand==1,{
				note=note-12;
			});
			bassnote=scale[bassnote.mod(scale.size)]+40;
			Synth.head(s,"bigbass",[\hz,bassnote.midicps,\duration,0.1,\release,0.5]);
			if (~noteSkip.rand==1,{
			},{
				Synth("jp",[\freq,note.midicps,\mix,(90+10.rand)/100,\detune,(25+30.rand)/100,\amp,syncs[i.mod(syncs.size)]]);
			});

			if (kick[0]>1,{
				// roll
				l.playKick(kickv,1,0,rate,20000,0,0,0,kick[0],4.0*bpm/60/kick[1].asFloat);
			},{
				if (kick[0]>0,{
					l.playKick(kickv,1,0,rate,20000,0,0,0,0,0);
				});
			});
			if (ride=="x",{
				l.playRide(ridev,0.3,0,rate,20000,0,0,0);
			});
			if (snar.asInteger>0,{
				// roll
				l.playSnare(snarv,1,0,rate,20000,0,0,0,snar.asInteger,snar.asInteger.asFloat*bpm/60);
			},{
				if (snar=="x",{
					l.playSnare(snarv,1,0,rate,20000,0,0,0,0,0);
				});
			});
			if (hiha.asInteger>0,{
				// roll
				l.playCH(hihav,2.0,0,rate,20000,0,0,0,hiha.asInteger,hiha.asInteger.asFloat*bpm/60);
			},{
				if (hiha=="x",{
					l.playCH(hihav,2,0,rate,20000,0,0,0,0,0);
				});
				if (hiha=="o",{
					l.playOH(hihav,1,0,rate,20000,0,0,0);
				});
			});
			1 });
	}.play;
});
)


(
Routine{
	var octav=[0,0,0,12,12,12,24,24];
	var scale=Scale.major;
	var notes=[0,2,4,0,2,4,0,2,0,2,4,0,2,4,0,2];
	var syncs=[1,1,0.5,1,1,0.5,0.5,1];
	notes=notes++[-1,2,4,-1,2,4,-1,2,-1,2,4,-1,2,4,-1,2];
	notes=notes++[-2,0,4,-2,0,4,-2,2,-2,0,4,-2,0,4,-2,2];
	notes=notes++[-2,0,3,-2,0,3,2,-2,0,3,-2,0,3,3,4,-1,5];
	inf.do({
		arg i;
		var note=notes[i.mod(notes.size)];
		note=scale[note.mod(scale.size)]+octav[i.mod(octav.size)]+40;
		Synth("jp",[\freq,note.midicps,\mix,(90+10.rand)/100,\detune,(30+30.rand)/100,\amp,syncs[i.mod(syncs.size)]]);
		0.125.wait;
	});
}.play;
)
