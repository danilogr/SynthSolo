import processing.sound.*;

SinOsc[] sineWaves; // array of sines
float[] sineFreq;   // array of frequencies
int numSines = 10;   // number of oscillators to use

FFT fft;
//AudioDevice device;
AudioIn in;

// Declare a scaling factor
int scale = 5;

// Define how many FFT bands we want
int bands = 512;

// declare a drawing variable for calculating rect width
float r_width;

// Create a smoothing vector
float[] sum = new float[bands];

// Create a smoothing factor
float smooth_factor = 0.2;

void setup()
{
  size(640, 480);
  
  
  sineWaves = new SinOsc[numSines];
  sineFreq  = new float[numSines];
  
  for (int i = 0; i < numSines; i++) {
    // Calculate the amplitude for each oscillator
    float sineVolume = (1.0 / numSines) / (i + 1);
    // Create the oscillators
    sineWaves[i] = new SinOsc(this);
    // Start Oscillators
    sineWaves[i].play();
    // Set the amplitudes for all oscillators
    sineWaves[i].amp(sineVolume);
  }
  

  // Calculate the width of the rects depending on how many bands we have
  r_width = width/float(bands);
  
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  

  // Create and patch the FFT analyzer
  fft = new FFT(this, bands);
  fft.input(in);
  
}

void draw() {
  
  background(0, 0, 0);
  fill(255, 0, 0);
  noStroke();  
  
  //Map mouseY from 0 to 1
  float yoffset = map(mouseY, 0, height, 0, 1);
  //Map mouseY logarithmically to 150 - 1150 to create a base frequency range
  float frequency = pow(1000, yoffset) + 150;
  //Use mouseX mapped from -0.5 to 0.5 as a detune argument
  float detune = map(mouseX, 0, width, -0.5, 0.5);

  for (int i = 0; i < numSines; i++) { 
    sineFreq[i] = frequency * (i + 1 * detune);
    // Set the frequencies for all oscillators
    sineWaves[i].freq(sineFreq[i]);
  }
  

  fft.analyze();
  for (int i = 0; i < bands; i++) {
    // Smooth the FFT data by smoothing factor
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;

    // Draw the rects with a scale factor
    rect( i*r_width, height, r_width, -sum[i]*height*scale );
  }  
  
}