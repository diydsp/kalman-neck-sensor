#include <stdio.h>
#include <math.h>
#include <stdlib.h>

float Fs       = 1000.0f;  // samp freq in Hz
float neck_var = 0.1f;   // variance of noise

float pos        = 0.0f; // kinetics
float pos_noise  = 0.0f;
float vel        = 0.0f;
float acc        = 0.0f;

float pos1       = 0.0f; // prev step
float pos_noise1 = 0.0f; 
float vel1       = 0.0f;

float dpos       = 0.0f; // derivatives
float dpos_noise = 0.0f;
float dvel       = 0.0f;

float noise      = 0.0f;

float noise_mag = 1 * 2000;

void out_row( void )
{
  noise = ( ( random()%(int32_t)noise_mag ) - noise_mag / 2.0f )/ noise_mag / 2.0f;
  pos_noise = pos + noise;

  dpos = pos - pos1;
  dpos_noise = pos_noise - pos_noise1;
  vel = dpos_noise * Fs;
  dvel = vel - vel1;
  acc = dvel * Fs;

  printf( "%.4f, ", pos );
  printf( "%03.4f, ", pos_noise );
  printf( "% 3.4f, ", dpos_noise );
  printf( "% 4.4f, ", vel );
  printf( "% 4.4f, ", dvel );
  printf( "% 4.4f, ", acc );
  printf( "\n" );

  // prep for next iter
  pos1       = pos;
  pos_noise1 = pos_noise;
  vel1 = vel;
}

void out_samps( float samp_len )
{
  int32_t step, steps = Fs * samp_len;
  float noise;
  
  for( step = 0; step < steps; step++ )
  {
    acc = 0;
    vel = 0;
    out_row();
  }

}

// e.g. freq of 5 Hz means period is 0.2s,
// so half that to move from cos( 0 ) to cos( pi ) is 0.1s
void move_to( float target, float freq )
{
  float   samp_len      = 1.0f / freq / 2.0f;
  int32_t step, steps   = Fs * samp_len;
  float   phase         = 0.0f;
  float   phase_delta   = M_PI / (float) steps;
  float   offset        = 0.0f;
  float   gap           = target - pos;
  float   noise;
  float   start_point   = pos;
  
  for( step = 0; step < steps; step++ )
  {
    offset  = gap * ( 0.5f - 0.5f * cos( phase ) );
    pos     = start_point + offset;
    out_row();
    
    phase  += phase_delta;
  }
  pos = target;
  
}

void main( void )
{

  pos = 0;
  out_samps( 0.1f );

  move_to( 100.0, 5 ); // move M mm, at N Hz

  out_samps( 0.1f );
}

