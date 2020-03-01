
#define en1 11
#define in1 9
#define in2 10


int rotDirection = 0;

void setup() {
  // put your setup code here, to run once:
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(en1, OUTPUT);
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);

    // initialize serial:
  Serial.begin(9600);

}

void loop() {
  // put your main code here, to run repeatedly:
while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    if (inChar == 'o') {
       digitalWrite(en1, HIGH);
       Serial.println("Motor is ON");       
    }
    else if (inChar == 'f'){
       digitalWrite(en1, LOW);
       Serial.println("Motor is OFF"); 
    }
}
}
