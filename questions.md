# Questions

## HPC good citizenship

1. On the UCI cluster, the resource request "-pe openmp 64" refers to the number of processors requested.  Does that
   request mean that your commands will use multiple processors?

   No, the number of cores being uses by a process is determined by the script of the code itself.   
   For example, R only use 1 core so there is no point to request more than 1 core.   

2. In general, how do you know how many processors, how much RAM, how many files would be required/needed/written by the
   jobs you are running on the cluster?

   running the process locally for test before submitting to cluster:   
      This command will measure memory usage: env time -v -o memorymearsure.txt command. the memorymeasure.txt is the output. Maximum resident set size in kilobytes are the memory used. file system input and output are number of input and output files of the command.       
      To see how many processor being used:      
         htop . Then f2 to go to setup, choose column on setup column,         
         then go to available column, then choose processor. F10 to done .         
         Now htop will show which core being used by the process.         
         The number of line will be the number of cores being used.         
      Another option is to use: ps -u$USER -o %cpu,rss,args. The total number     
      of line show the count of cores being use by the same args as indicated      
      by args column. Rss is the memory being use in kilobytes      

   the job has already been running on SGE cluster.   
      Use qstat -u USERNAME. This will show the status of the job. On the queue column, it will be username@compute_node. For example, khoih@compute-1-1. Then, we can manually log into the compute node with ssh compute-1-1. Then we can use either the ps option or the above htop options to monitor the processor usage or memory usage.       

3. In order to be a "good citizen", you need to have some idea of much RAM your job requires.  In particular, you need
   to know the "peak" (i.e., maximum) RAM required at any point during execution.  Show an example of the shell command
   that you would use on a Linux machine to measure run time and peak ram usage of an arbitrary command, where the time/peak RAM values are written to a file.


   env time -f "Elapsed time in clock format: %E, Max resident set size in kilobyte(peak memory) : %M" -o measurement.txt ls   
   measurement.txt is the output of the time command. ls is the command being run.   


4. What are the units of your answer for number 3?

   Elasped time is in clock format of hour:minute.second and memory is in kilobytes   


5. What are the bash commands for the following operations:

    * Checking that a file exists

```
if [ -e "somefile.txt" ]; 
then 
echo "somefile.txt exist" 
else 
echo "somefile.txt doesn't exist" 
fi
```


    * Checking that a file exists and is not empty

```
if [ -s "somefile.txt" ]; 
then 
echo " somefile.txt exists and is not empty " 
else 
echo " somefile.txt does not exist, or is empty " 
fi
```





6. How would you use the commands from your answer to 5 to write a work flow for HPC that only runs a job if the
   expected output file is **not** present.


```
#!/bin/bash
#$ -N processname
#$ -q pub8i,pub64 
#$ -pe openmp 2
#$ -R y
#$ -t 1

if [ -e "somefile.txt" ];
then
echo "somefile.txt exist"
else
echo "somefile.txt doesn't exist"
Do some command  
fi
```




## Trickier questions

7. Would your answer to number 3 work on Apple OS X operating system?  If no, do you have any idea why not? 


   The answer for number 3 with usage of gnu time can also work on Apple OS X but require installing of gnu time via command line : brew install gnu-time   
   (brew is a command from homebrew packaage management)   

8. Most of the HPC nodes have 512Gb (gigabytes) of RAM. Let say you have a job that will require **no more** than 24Gb
   of RAM.  How would you request resources so that you can run more than one job on a node **and** not cause nodes to
   crash?  Show an example of a skeleton HPC script as part of your answer.  **Knowing how to do this is super important
   and will save you loads of frustration and prevent you from taking out your colleagues jobs on the cluster,
   preventing you from getting nasty emails from Harry!!!!!!!!!!!**

   Assuming the node has 512gb and 64 cores that comes out to 8gb/core.   
   Since we need 24gb of memory, it will require 25/8 =3.125cores.   
   If the result of core is in decimal, always round up.   
   Therefore, we need 4 cores for 25 gb of memory Then, the SGE job script will need to have   

```
#$ -pe openmp 4
#$ -l mem_free=25GB
```

   This way, our job will be run with 25GB using 4 cores on a node and will not crash the cluster.   
   example jobscript using the question 6 samnple:

```
#!/bin/bash
#$ -N processname
#$ -q pub8i,pub64
#$ -pe openmp 4
#$ -l mem_free=25GB
#$ -R y
#$ -t 1

if [ -e "somefile.txt" ];
then
echo "somefile.txt exist"
else
echo "somefile.txt doesn't exist"
Do some command
fi
```


