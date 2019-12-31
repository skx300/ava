AVA: A Graphical User Interface for Automatic Vibrato and Portamento Detection and Analysis

AVA is an automatic vibrato and portamento detection and analysis tool. It accepts raw audio and automatically tracks the vibrato and portamento to display their expressive parameters for inspection and further statistical analysis. The applications of AVA include music education and expression analysis, and its outputs provide a useful base for expression synthesis and transformation.

The AVA is written by Luwei Yang and Khalid Z. Rajab at Queen Mary University of London. Please contact Luwei Yang (l.yang@qmul.ac.uk) for any enquiries. 

License: The QMUL Research Software License Agreement (in the package) for research use.

Requirement: Matlab

Installation: click AVA.mlappinstall file to install this toolbox into Matlab.

The interface includes following pitch detection methods:

- Yin: the Matlab code was written by Alain de Cheveigné, which is available in http://audition.ens.fr/adc/.

-Pyin(Matlab): this is a matlab implementation for the pyin method (a probabilisitic version of the Yin method developed by Matthias Mauch) written by Luwei Yang using a simplistic Viterbi decoding. This matlab implementation requires some original yin matlab functions.

-Pyin(Tony): a C++ implementation written by the original pyin author Matthias Mauch in Sonic Visualiser Vamp plugin. If you want to use this method, you need to
	1. Download the pyin vamp plugin at http://www.vamp-plugins.org/download.html and a Sonic Annotator at http://www.vamp-plugins.org/sonic-annotator/. Following the vamp plugin installation instructions for vamp plugin to install the pyin plugin. 
	2. Put the sonic-annotator into your Matlab search path.
	3. Put the pyinParameters.n3 (in the package) file into your Matlab search path.

Citation of the following publications is appreciated.

- Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: A Graphical User Interface for Automatic Vibrato and Portamento Detection and Analysis, In Proc. of the 42nd International Computer Music Conference, 2016.
- Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: An Interactive System for Visual and Quantitative Analyses of Vibrato and Portamento Performance Styles, In Proc. of the 17th International Society for Music Information Retrieval Conference, 2016.


