# Functional Connectivity Analysis

## Overview

This github contains the code use for analysis conducted at Baycrest research Hosptial under the guidance of [Dr.Zhongxu Liu](http://psych.utoronto.ca/Neuropsychologylab/zhongxu.html) . Most of the code, if not adapted from Dr.Liu's source material are written based on his direct direction.

## Code

The code is written in Python, Matlab and bash and tcl. Throughout the project it is assumed that the subject's data is in the same folder as The script folder. Such that from the main project directory, Data/Raw_data finds the raw data files.

The code relies heavily on :

* [SPM Toolbox](http://www.fil.ion.ucl.ac.uk/spm/)
* [Conn Toolbox](https://www.nitrc.org/projects/conn)
* [Freesurefer](https://surfer.nmr.mgh.harvard.edu/)

### Goals:

The aim of this project is to perform functional connectitivty analysis on the Oculomotor and memory system. The data used is the same as that of Dr.Liu's phd projct (link) . No data available on this repo due to obvious ethical cocerns.

## Detaild Explanation 

### 0. [Setup](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/0.%20Setup)

[0.1](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/0.%20Setup/StructCreating.m) Renaming Folders : The folder names produced based on the trial and block order were changed to reflect the name of the condition as shown below . A structure called mysubject was created to retain the name changes and be used later for analysis.


```python
RunNames =   {  'preencoding_rest'
                'encoding_fam1'
                'encoding_fam2'
                'post_encoding_rest_fam'
                'encoding_nonfam1'
                'encoding_nonfam2'
                'post_encoding_rest_nonfam'
                'localizer_task'
                'thinkback'
                'thinkahead' };

OrgFileNames = {    '4_OB-AX  ep2d_bold ~184~Pre'
                    '5_OB-AX  ep2d_bold ~ 290'
                    '6_OB-AX  ep2d_bold ~ 290'
                    '7_OB-AX  ep2d_bold ~184~Post 1'
                    '8_OB-AX  ep2d_bold ~ 290'
                    '9_OB-AX  ep2d_bold ~ 290'
                    '10_OB-AX  ep2d_bold ~184~Post 2'
                    '11_OB-AX  ep2d_bold ~ 292'
                    '12_OB-AX  ep2d_bold ~184~Post 3 ~Task'
                    '13_OB-AX  ep2d_bold ~184~Post 4~Task'
                    '3_T1 MPRAGE OB-AXIAL'
                };
```

### 1. [PreProcess](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/1.%20PreProcess)  


[1.1](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/1.%20PreProcess/1.1%20-%20Diciom%20to%20Nifi/DicomToNifti_LoopAllSubjects.m)  Dicom To Nifit: the files had to be converted to .nii formats. This was done in Matlab, using SPM.

1.2 ReOrientation: The Anantomical images for each subject were reoriented using SPM. For all Subjects, the (0,0) point was adjusted as to reflect the hippocampus

[1.3](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/1.%20PreProcess/1.8%20Spm_Preprocess) [Spm_PreProcess](https://github.com/ATajadod94/Functional-Connectivity-Analysis/blob/master/Code/1.%20PreProcess/1.8%20Spm_Preprocess/PostOrgLoop.m) : The data was preprocessed using the SPM toolbox. The 6 preprocessign steps were done through one spm batch. The result data from each step was saved and specified with prefixes inidcated below. A short explanation and the name of the steps is available here.


    1.3.1 Time Slicing : The time delay is adjusted for each participant. Prefix 'a'

    1.3.2 Realign And Estimate: The brain data images were realigned. Prefix 'r'

    1.3.3 Coregister: This step is done to superimpose the anatomy and functional images onto one another. The anatomical image was used as the mean.  Prefix 'e'

    1.3.4 Segmentation: The anatomical image is selected and segmented into white matter , grey matter and CSF. this is all done in the native space. AS the data output is saved with a different name, no Prefix is neccesary.

    1.3.5 Normalize: This step is done to be able to compare data across individuals in a normalized template.The MNI tempelated is used as the standard tempelate. Using the anatomical image as the mean, functional images are then resliced and normalized to  the anatomical data.

    1.3.6 Smooth: The nomralized functional data are smoothed for analysis.

This portion of the document is adapted based on a document written up written by [Amir zarie](https://www.linkedin.com/in/amir-zarie-9807b4aa/)


### 2. [FirstLevel Analysis](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/2.%20FirstLevel)

First level analysis were performed on the smooth data, sepertatly on each subject for the Task conditions and localization conditions. This step was once again automated via one spm batch. A short explanation and the name of the steps is available here.  Sepertate scripts were create to reflect the change in the contrasts for Localizer and Task trials as well as analysis done in Native and MNI steps.


 2.1: Behaviorual condition files were used to create the regressors. Previously avaialble condition files were used to set the onsets, and condition details for the data.

 2.2: Model Estimation: The Classic spm method was used for estimating the model . Prefix 'e'

 2.3: Contrast manager: Regression data were created and saved using the specified contrats below.




```python
contrastnames = {'facehouse','scrambled','face-scrambled','fam1','scramb1','fam2','scramb2','nonfam1','scramb3','nonfam2','scramb4'};
contrastvects = {[1],[0,1],[1,-1],[1],[0,1],[zeros(1,8),1],[zeros(1,8),0,1],...
    [zeros(1,8),zeros(1,8),1],[zeros(1,8),zeros(1,8),0,1],...
    [zeros(1,8),zeros(1,8),zeros(1,8),1],[zeros(1,8),zeros(1,8),zeros(1,8),0,1]};
```

### 3. [Freesurfer](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/3.%20FreeSurfer)

Shell scripts were used in combination with freesurfer's toolbox. Recon-all function was used to create labels for all subjects in the fs space.

### 4. [Creating labels](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/4.%20Label_Code)

   4.1: Adopting code provided by Glasser and Griffis (links) labels were created for each indivual subject. Code for these steps is not available on github as of yet as we do not have the author's explicit premission.

   4.2: [Creating labels](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/4.%20Label_Code/Segmenting) : In this step, python, matlab and tcl code was uesd.

    we cut the left and right , Hippocampus, EntoRhinal, Parahippocampius and Fusiform of the participants into different segments of the same size. To do so, the subject's mri image was imported and the data was converted to the real world cordinates. Thereafter, the normal plane for reach region of each participant was automatically calcualtedand used to to cut the specified region into the number of parts indicated previously by Dr.Liu. The created labels were saved to be used later as ROI's in the analysis

  4.3: [Mapping Anatomical ROI's to functional images](https://github.com/ATajadod94/Functional-Connectivity-Analysis/tree/master/Code/4.%20Label_Code/4.3%20Mapping) : In this step was are using Conn's connectivty toolbox to map the calculated ROI from the previous steps to each Subject's functional data. Taking advantage of existing processes in Conn's toolbox, further preprocessing steps was performed to denoise the data.
