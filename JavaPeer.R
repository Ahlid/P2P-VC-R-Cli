
startJava <- function(token, port, machineId, machineToken){

library(rJava)
.jinit("C:/Users/tiago/IdeaProjects/withMaven/target/classes")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/charsets.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/deploy.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/access-bridge-64.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/cldrdata.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/dnsns.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/jaccess.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/jfxrt.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/localedata.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/nashorn.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/sunec.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/sunjce_provider.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/sunmscapi.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/sunpkcs11.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/ext/zipfs.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/javaws.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/jce.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/jfr.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/jfxswt.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/jsse.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/management-agent.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/plugin.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/resources.jar")
.jaddClassPath("C:/Program Files/Java/jdk1.8.0_241/jre/lib/rt.jar")
.jaddClassPath("C:/Users/tiago/IdeaProjects/withMaven/target/classes")
.jaddClassPath("C:/Users/tiago/.m2/repository/io/socket/socket.io-client/1.0.0/socket.io-client-1.0.0.jar")
.jaddClassPath("C:/Users/tiago/.m2/repository/io/socket/engine.io-client/1.0.0/engine.io-client-1.0.0.jar")
.jaddClassPath("C:/Users/tiago/.m2/repository/com/squareup/okhttp3/okhttp/3.8.1/okhttp-3.8.1.jar")
.jaddClassPath("C:/Users/tiago/.m2/repository/com/squareup/okio/okio/1.13.0/okio-1.13.0.jar")
.jaddClassPath("C:/Users/tiago/.m2/repository/org/json/json/20171018/json-20171018.jar")

obj <- .jnew("Main")
s <- .jcall(obj, returnSig = "V", "main", .jarray(c(token, port, machineId, machineToken)) )

.remotIST$JavaMachine <- obj

}

stopJava <- function (){
  s <- .jcall(.remotIST$JavaMachine, returnSig = "V", "stop")
}


