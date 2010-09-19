echo -ne "\033k${HOST##* }\033\\"; 
ssh_pr () {	
old_host=$HOST
args=$@; 
echo -ne "\033k${args##* }\033\\"; 
command ssh "$@"    
echo -ne "\033k${old_host##* }\033\\";
}

#CVSROOT="/p/mpg/proc/common/cvs_repository/pv"