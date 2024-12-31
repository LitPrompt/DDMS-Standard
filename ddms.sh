#!/bin/bash
JAVA_EXECUTABLE=~/.sdkman/candidates/java/current/bin/java
export PATH=$PATH:/usr/bin
# Copyright (C) 2007 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get the script's directory
prog_dir="$(dirname "$(readlink -f "$0")")"

# Check if Java is available
if [[ ! -x "$JAVA_EXECUTABLE" ]]; then
    echo "Java executable not found at $JAVA_EXECUTABLE"
    exit 1
fi

# Set up framework directories and jar file
jarfile="ddms.jar"
frameworkdir="$prog_dir"

if [[ ! -f "$frameworkdir/$jarfile" ]]; then
    frameworkdir="$prog_dir/lib"
fi

if [[ ! -f "$frameworkdir/$jarfile" ]]; then
    frameworkdir="$prog_dir/../framework"
fi

if [[ ! -f "$frameworkdir/$jarfile" ]]; then
    echo "Could not find $jarfile in any known locations."
    exit 1
fi

# Debug mode
if [[ "$1" == "debug" ]]; then
    java_debug="-agentlib:jdwp=transport=dt_socket,server=y,address=8050,suspend=y"
    shift
else
    java_debug=""
fi

# Set SWT path
if [[ -z "$ANDROID_SWT" ]]; then
    swt_path="$(java -jar "$frameworkdir/archquery.jar")"
    swt_path="$frameworkdir/$swt_path"
else
    swt_path="$ANDROID_SWT"
fi

if [[ ! -d "$swt_path" ]]; then
    echo "SWT folder '$swt_path' does not exist."
    echo "Please set ANDROID_SWT to point to the folder containing swt.jar for your platform."
    exit 1
fi

# Launch DDMS
jarpath="$frameworkdir/$jarfile:$frameworkdir/swtmenubar.jar"
echo "The standalone version of DDMS is deprecated."
echo "Please use Android Device Monitor (monitor.sh) instead."
java $java_debug -Djava.library.path="$prog_dir/x86_64" -classpath "$jarpath:$swt_path/swt.linux.jar" com.android.ddms.Main "$@"

