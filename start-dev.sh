#!/bin/sh
cd `dirname $0`
riak start
exec erl -pa $RIAK_EBIN -pa $PWD/ebin $PWD/deps/*/ebin $PWD/deps/*/deps/*/ebin -name webwork -setcookie riak -boot start_sasl -s reloader -s webwork
