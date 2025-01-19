/*
  Module Test

 A simple test program based on the Webserver demo

 This test is meant to be used from a microcontroller with the module
 plugged into the mcu, with the mcu plugged into the FPGA in order
 to perform tests serially.

 Setup:
 * Connect SPI bus MOSI/MISO/SCK/CS between MCU and W5500 module
 * Connect USB to MCU
 * Connect Ethernet cable from W5500 module to router
 * Analog inputs attached to pins A0 through A5 (optional)
 * Update IP address below if needed to match network
 * Open Serial Monitor window
 * The default IP address is 10.0.0.12
 */

#include <SPI.h>
#include <Ethernet.h>

// Enter a MAC address.  Can usually be arbitrary
byte mac[] = {
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED
};

// The IP address will be dependent on your local network
// First 3 numbers must match router, last must be unique
IPAddress ip(10, 0, 0, 12);

// Initialize the Ethernet server library with the IP address and port
// to use.  (port 80 is default for HTTP):
EthernetServer server(80);
//===============================================================================
//  Initialization
//===============================================================================
void setup() {
  Serial.begin(9600);
  Serial.println("Ethernet Test");

  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);

  // Check for Ethernet hardware present
  if (Ethernet.hardwareStatus() == EthernetNoHardware) {
    Serial.println("Ethernet module was not found - Stopping Test");
    while (true) {
      delay(1); // do nothing, no point running without Ethernet hardware
    }
  }

  // start the server
  server.begin();
  Serial.print("server is at ");
  Serial.println(Ethernet.localIP());
}
//===============================================================================
//  Main
//===============================================================================
void loop() {
  // listen for incoming clients
  EthernetClient client = server.available();
  if (client) {
    Serial.println("new client");
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        Serial.write(c);
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println("Connection: close");  // the connection will be closed after completion of the response
          client.println("Refresh: 5");  // refresh the page automatically every 5 sec
          client.println();
          client.println("<!DOCTYPE HTML>");
          client.println("<html>");
          // output the value of each analog input pin
          for (int analogChannel = 0; analogChannel < 6; analogChannel++) {
            int sensorReading = analogRead(analogChannel);
            client.print("analog input ");
            client.print(analogChannel);
            client.print(" is ");
            client.print(sensorReading);
            client.println("<br />");
          }
          client.println("</html>");
          break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
    Serial.println("client disconnected");
  }
}


