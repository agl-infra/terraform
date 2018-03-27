ip=$(head -25 /var/jenkins_home/workspace/InfrastructurePipeline/vinnet/vm-output.json | tail -1 | awk '{print $2}' | sed -e 's/^"//' -e 's/"$//')
ssh -t 'root@40.83.187.131' 'sshpass -f password.txt ssh-copy-id vineet@'$ip''
#ssh -t  vineet@$ip
ssh -t 'root@40.83.187.131' ip="$ip" bash -s<<'SSH_EOF'
ssh -t  vineet@$ip 'echo TCS#1234 | sudo -S sh -c "echo '104.209.37.199 scealmserver.touni4lqw3eunhr30cggzt5izh.dx.internal.cloudapp.net'>> /etc/hosts"'
SSH_EOF
ssh -t 'root@40.83.187.131' 'cd chef-repo && knife bootstrap '$ip' -x vineet -P TCS#1234 --sudo --run-list role[web]'
