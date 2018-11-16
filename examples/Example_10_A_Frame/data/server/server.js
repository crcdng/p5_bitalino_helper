const OSC = require('osc-js');

const config = {
  udpServer: {
      host: 'localhost',
      port: 9130,   // Processing sketch: RECEIVER_UDP_PORT
    },
    udpClient: {
      host: 'localhost',
      port: 9129    // Processing sketch: MY_UDP_PORT
    },
    wsServer: {
      host: 'localhost',
      port: 8080
    }
};

const osc = new OSC({ plugin: new OSC.BridgePlugin(config) });
osc.open();

osc.on('/aframe/inputs', message => {
  // console.log(message);
  // FIXME osc-js message contains a "," as the first type string received from oscP5
  // which causes an error in the browser osc-js receiver
  message["types"] = message["types"].slice(1);
  osc.send(message);
});
