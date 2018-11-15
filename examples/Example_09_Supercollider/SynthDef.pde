// sounds horrible :)

/*

SynthDef(\synth1, { |outbus = 0, amp = 0.5, input = 440, pan = 0|
        var data;
        input = Lag.kr(input, 0.1);
        data = SinOsc.ar(input, 0, amp);
        Out.ar(outbus, Pan2.ar(data, pan));
}).store;

SynthDef(\synth2, { |outbus = 0, amp = 0.5, input = 440, pan = 1|
        var data;
        input = Lag.kr(input, 0.1);
        data = SinOsc.ar(input, 0, amp);
        Out.ar(outbus, Pan2.ar(data, pan));
}).store;


*/
