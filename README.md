# MATLAB code for Real-time Timbre Transfer and Sound Synthesis using DDSP
This repository contains MATLAB code for the Real-time Timbre Transfer and Sound Synthesis using DDSP project at https://github.com/SMC704/juce-ddsp

## Usage
The code in this repository is suposed to be transpiled to C++ using the MATLAB Coder plugin. 

To do this open the DDSPSynth.prj file with the MATLAB Coder plugin and follow the steps in the Coder wizard. 

The Coder is dependent on the generate_cpp_helper.m file, which should be updated if changes are made to the general MATLAB implementation. 

Generated .h and .cpp files code should be copied from the codegen/lib/DDSPSynth folder to Source/codegen folder in the https://github.com/SMC704/juce-ddsp repo.