#!/usr/bin/env python


import os
import sys


jdl = """\
universe = vanilla
executable = ./job.sh
output = out/$(ProcId).$(ClusterID).out
error = err/$(ProcId).$(ClusterID).err
log = log/$(ProcId).$(ClusterID).log
requirements = (OpSysAndVer =?= "SLCern6")
max_retries = 3
RequestCpus = 1
+MaxRuntime = 28800
queue arguments from arguments.txt\
"""


def mkdir(path):
    if not os.path.exists(path):
        os.mkdir(path)


def parse_arguments():
    if not len(sys.argv) == 2:
        raise Exception("./create_job.py PATH_TO_JOBDIR")
    return {"jobdir": sys.argv[1]}


def main(args):
    # Build argument list
    num_events = 10000
    print("Number of events per mass point: {}".format(num_events))
    arguments = []
    counter = 0
    mass_points = range(50, 250)
    print("Mass points: {}".format(mass_points))
    for mass in mass_points:
        arguments.append("%u %f %u\n" % (counter, mass, num_events))
        counter += 1
    print("Number of jobs: %u" % len(arguments))

    # Create jobdir and subdirectories
    jobdir = os.path.join(args["jobdir"])
    print("Jobdir: %s" % jobdir)
    mkdir(jobdir)
    mkdir(os.path.join(jobdir, "out"))
    mkdir(os.path.join(jobdir, "log"))
    mkdir(os.path.join(jobdir, "err"))

    # Write jdl file
    out = open(os.path.join(jobdir, "job.jdl"), "w")
    out.write(jdl)
    out.close()

    # Write argument list
    arglist = open(os.path.join(jobdir, "arguments.txt"), "w")
    for a in arguments:
        arglist.write(a)
    arglist.close()

    # Write job file
    jobfile = open("job.sh", "r").read()
    job = open(os.path.join(jobdir, "job.sh"), "w")
    job.write(jobfile)
    job.close()


if __name__ == "__main__":
    args = parse_arguments()
    main(args)
