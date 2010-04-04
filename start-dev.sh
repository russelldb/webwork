#!/bin/sh
cd `dirname $0`
sudo /usr/local/riak/rel/riak/bin/riak start
exec erl -pa $PWD/ebin $PWD/deps/*/ebin $PWD/deps/*/deps/*/ebin -name webwork -setcookie riak -boot start_sasl -s reloader -s webwork -config webwork.config 
