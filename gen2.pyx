
import random as rand
import math as math

cdef float Fs         = 1000.0  # samp freq in Hz
cdef float neck_var   = 0.1   # variance of noise

cdef float pos        = 0.0 # kinetics
cdef float pos_noise  = 0.0
cdef float vel        = 0.0
cdef float acc        = 0.0

cdef float pos1       = 0.0 # prev step
cdef float pos_noise1 = 0.0 
cdef float vel1       = 0.0

cdef float dpos       = 0.0 # derivatives
cdef float dpos_noise = 0.0
cdef float dvel       = 0.0

cdef float noise      = 0.0

cdef float noise_mag = 1 * 2000

def out_row():
    #noise = rand.uniform( -noise_mag/2.0, noise_mag / 2.0 )
    noise = 0.5;
    pos_noise = pos + noise

    dpos = pos - pos1
    dpos_noise = pos_noise - pos_noise1
    vel = dpos_noise * Fs
    dvel = vel - vel1
    acc = dvel * Fs

    print(f'{pos: 3.4f}, ', end='' )
    print(f'{pos_noise: 3.4f}, ', end='')
    print(f'{dpos_noise: 3.4f}, ', end="" )
    print(f'{vel: 4.4f}, ', end="" )
    print(f'{dvel: 4.4f}, ', end="" )
    print(f'{acc: 4.4f}, ', end="" )
    print(f'\n' )
    
    # prep for next iter
    pos1       = pos
    pos_noise1 = pos_noise
    vel1 = vel

def out_samps( float samp_len ):

    cdef int32_t step
    cdef int32_t steps = Fs * samp_len
    cdef float noise

    for step in range( 0, steps):
        acc = 0
        vel = 0
        out_row()


# e.g. freq of 5 Hz means period is 0.2s,
# so half that to move from cos( 0 ) to cos( pi ) is 0.1s
def move_to( target, freq ):
    cdef float   samp_len      = 1.0 / freq / 2.0
    cdef int32_t step
    cdef int32_t steps   = Fs * samp_len
    cdef float   phase         = 0.0
    cdef float   phase_delta   = M_PI / steps
    cdef float   offset        = 0.0
    cdef float   gap           = target - pos
    cdef float   noise
    cdef float   start_point   = pos
  
    for step in range( 0, steps ):
        offset  = gap * ( 0.5 - 0.5 * math.cos( phase ) )
        pos     = start_point + offset
        out_row()
        phase  += phase_delta

    pos = target


pos = 0
out_samps( 0.1 )

move_to( 100.0, 5 ) # move M mm, at N Hz

out_samps( 0.1 )

