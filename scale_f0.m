function f0_scaled = scale_f0(f0_in, to_midi)
    f0_range = 127;
    
    f0_scaled = zeros(100,1);
    if(to_midi == true)
       if(f0_in(1) == -1)
           note = 0;
       else
           note = 12*(log2(f0_in(1)) - log2(440)) + 69; 
       end
       f0_scaled(1:end) = note;
       f0_scaled = f0_scaled / f0_range;
    end
    
    if(to_midi == false)
        for i = 1:100
           f0_scaled(i) = 440 * pow2((f0_in(i)*f0_range - 69) / 12);
        end
    end
end