# Consul-template && haproxy1.7.6
Service discovery for mesos&amp;marathon architecture

如何使用该git的资源，如下 

你可以利用Dockerfile制作一个镜像

docker images docker build -t haproxy_consul . 

对制作完成的镜像，使用注意以下几点 

本镜像是结合了haproxy supervisor consul-template三个组件合成一个镜像 

	1. supervisor的日志保存在/applog/supervisor目录中 
	
	2. consul-template的日志保存在/applog/consul-template目录下 
	
	3. haproxy的日志是通过rsyslog udp协议传递到宿主机上，你需要在宿主机配置rsyslog接收haproxy日志 
	
docker run 参数如下

docker run -d --net host --name consul-haproxy --restart=always \\

	--log-opt max-file=10 --log-opt max-size=20k \\
	
	-v /applog/supervisor:/applog/supervisor:rw \\
	
	-v /applog/consul-template:/applog/consul-template:rw \\
	
	haproxy_consul
 
