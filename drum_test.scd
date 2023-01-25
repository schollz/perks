
(
s.waitForBoot({
    s.record;
    l=LorenzosDrums2.new(Server.default,"/home/zns/Documents/perks/lorenzos-drums/");
    l.setFxParam("sine_drive",0.0);
    l.setFxParam("drive",0.0);
    l.setFxParam("compress_curve_wet",0.0);
    l.setFxParam("compress_curve_drive",1);
    l.setFxParam("expand_curve_wet",0.0);
    l.setFxParam("expand_curve_drive",1);
    ~kick_riddim="x-x-----x-x-----";
    ~kick_riddim="x-x-------xx----";
    ~kick_riddim="x-x-------x-----";
    ~kick_riddim="--xx------x-----";
    ~kick_riddim="x-x-----x-x-----";
    ~kick_riddim="x---x---x---x---";
    ~snar_riddim="----x--x-x--x--x";
    ~snar_riddim="----x--x----x--x";
    ~snar_riddim="----x--x-x----x-";
    ~snar_riddim="----x--x----x--x";
    ~snar_riddim="----x--x----x--4";
    ~snar_riddim="----x--x----44x4";
    ~snar_riddim="-x--x--x-x----x-";
    ~hiha_riddim="xox-xxx-xxx-xxxx";
    ~ride_riddim="x-x-x-x-x-x-x-x-";
    ~hiha_riddim="-";
    ~ride_riddim="-";
    Routine{
        var bpm=120;
        var tpb=60/bpm/4;
	var snar_vel=[1,1,0,1,1,0,1,0];
	var kick_vel=[1,0,1,1];
	var ride_vel=[1,1,0,1,1,0,1,1];
	var hiha_vel=[1,0,1,0,1,0,1,0,1,1,0,1,1,0,1,0];
	var slop=20; // +/- milliseconds
	1.wait;
        inf.do({  arg i;
            var rate=1;
            var beat=i.mod(16);
            var kick=~kick_riddim[beat].asString;
            var snar=~snar_riddim[beat].asString;
            var hiha=~hiha_riddim[beat].asString;
            var ride=~hiha_riddim[beat].asString;
	    var snarv=snar_vel[i.mod(snar_vel.size)]*30+30.rand+30;
	    var kickv=kick_vel[i.mod(kick_vel.size)]*30+30.rand+30;
	    var ridev=ride_vel[i.mod(ride_vel.size)]*30+10.rand+60;
	    var hihav=hiha_vel[i.mod(hiha_vel.size)]*30+10.rand+60;
            if (kick=="x",{
                l.playKick(kickv,1,0,1,20000,0,0,0);
            });
            if (ride=="x",{
                l.playRide(ridev,1,0,1,20000,0,0,0);
            });
            if (snar.asInteger>0,{
                // roll
                Routine{
                    snar.asInteger.do({ arg j;
	    		var snarv2=snar_vel[(i+j).mod(snar_vel.size)]*30+60;
                        l.playSnare(snarv2,1,0,rate,20000,0,0,0);
                        (tpb/snar.asInteger).wait;
                    })
                }.play;
            },{
                if (snar=="x",{
                    l.playSnare(snarv,1,0,rate,20000,0,0,0);
                });
            });
            if (hiha.asInteger>0,{
                // roll
            },{
                if (hiha=="x",{
                    l.playCH(hihav,1,0,rate,20000,0,0,0);
                });
                if (hiha=="o",{
                    l.playOH(hihav,1,0,rate,20000,0,0,0);
                });
            });
            (tpb+(((slop*2).rand-slop)/1000)).wait;
        });
    }.play;
    Routine {
	8.wait;
	0.exit;
    }.play;
});
)
