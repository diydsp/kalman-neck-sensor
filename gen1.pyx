

cdef float Fs       = 1000.0f  # samp freq in Hz
cdef float neck_var = 0.1f   # variance of noise

cdef float pos        = 0.0f # kinetics
cdef float pos_noise  = 0.0f
cdef float vel        = 0.0f
cdef float acc        = 0.0f

cdef float pos1       = 0.0f # prev step
cdef float pos_noise1 = 0.0f 
cdef float vel1       = 0.0f

cdef float dpos       = 0.0f # derivatives
cdef float dpos_noise = 0.0f
cdef float dvel       = 0.0f

cdef float noise      = 0.0f

cdef float noise_mag = 1 * 2000

def out_row():
{
    noise = ( ( random()%(int32_t)noise_mag ) - noise_mag / 2.0f )/ noise_mag / 2.0f
    pos_noise = pos + noise

    dpos = pos - pos1
    dpos_noise = pos_noise - pos_noise1
    vel = dpos_noise * Fs
    dvel = vel - vel1
    acc = dvel * Fs

    print(f'{pos: 3.4f}, ', endl="" )
    print(f'{pos_noise: 3.4f, ', endl="")
    print(f'{dpos_noise: 3.4f, ', endl="" )
    print(f'{vel: 4.4f, ', endl="" )
    print(f'{dvel: 4.4f, ', endl="" )
    print(f'{acc: 4.4f, ', endl="" )
    print(f'\n' )
    
    # prep for next iter
    pos1       = pos
    pos_noise1 = pos_noise
    vel1 = vel
}

def out_samps( cdef float samp_len ):
{
    cdef int32_t step
    cdef int32_t steps = Fs * samp_len
    cdef float noise
  
    for step in range( 0, steps):
    acc = 0
    vel = 0
    out_row()
}

# e.g. freq of 5 Hz means period is 0.2s,
# so half that to move from cos( 0 ) to cos( pi ) is 0.1s
def move_to( cdef float target, cdef float freq ):
{
    cdef float   samp_len      = 1.0f / freq / 2.0f
    cdef int32_t step
    cdef int32_t steps   = Fs * samp_len
    cdef float   phase         = 0.0f
    cdef float   phase_delta   = M_PI / (float) steps
    cdef float   offset        = 0.0f
    cdef float   gap           = target - pos
    cdef float   noise
    cdef float   start_point   = pos
  
    for step in range( 0, steps ):
    offset  = gap * ( 0.5f - 0.5f * cos( phase ) )
    pos     = start_point + offset
    out_row()
    
    phase  += phase_delta

    pos = target
}

pos = 0
out_samps( 0.1f )

move_to( 100.0, 5 ) # move M mm, at N Hz

out_samps( 0.1f )

