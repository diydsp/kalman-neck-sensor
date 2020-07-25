#include <stdio.h>
#include <math.h>
#include <stdlib.h>

float Fs       = 1000.0f;
float neck_var = 0.1f;

float pos      = 0.0f;
float vel      = 0.0f;
float noise    = 0.0f;
 
void out_row( void )
{
  noise = ( ( random()%2000 ) - 1000 )/ 1000.0f;

  printf( "%f, ", pos );
  printf( "%f, ", pos + noise );
  printf( "\n" );
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

