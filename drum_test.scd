
(
s.waitForBoot({
    l=LorenzosDrums2.new(Server.default,"/path/to/samples");
    ~kick_riddim="x---x---x---x---";
    ~snar_riddim="----x-------x---";
    ~kick_riddim="x-x-----x-x-----";
    ~snar_riddim="----x--x----x--x";
    ~snar_riddim="----x--x----x--4";
    ~hiha_riddim="xox-xxx-xxx-xxxx";
    ~ride_riddim="x---x---x--x-x--";
    Routine{
        var bpm=160;
        var tpb=60/bpm/4;
        inf.do({  arg i;
            var beat=i.mod(16);
            var kick=~kick_riddim[beat].asString;
            var snar=~snar_riddim[beat].asString;
            var hiha=~hiha_riddim[beat].asString;
            var ride=~hiha_riddim[beat].asString;
            if (kick=="x",{
                l.playKick(60,1,0,1,20000,0,0,0);
            });
            if (ride=="x",{
                l.playRide(60,1,0,1,20000,0,0,0);
            });
            if (snar.asInteger>0,{
                // roll
                Routine{
                    snar.asInteger.do({
                        l.playSnare(60,1,0,1,20000,0,0,0);
                        (tpb/snar.asInteger).wait;
                    })
                }.play;
            },{
                if (snar=="x",{
                    l.playSnare(60,1,0,1,20000,0,0,0);
                });
            });
            if (hiha.asInteger>0,{
                // roll
            },{
                if (hiha=="x",{
                    l.playCH(60,1,0,1,20000,0,0,0);
                });
                if (hiha=="o",{
                    l.playOH(60,1,0,1,20000,0,0,0);
                });
            });
            (tpb).wait;
        });
    }.play;
});
)
