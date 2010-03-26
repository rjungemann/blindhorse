SCRIPT_PATH="${BASH_SOURCE[0]}";
if([ -h "${SCRIPT_PATH}" ]) then
  while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd > /dev/null

export PATH=${SCRIPT_PATH}/bin:${SCRIPT_PATH}/sbin:$PATH
export PATH=${SCRIPT_PATH}/homebrew/bin:${SCRIPT_PATH}/homebrew/sbin:$PATH

export GEM_HOME=${SCRIPT_PATH}/homebrew/lib/ruby/gems

export PATH=${GEM_HOME}/bin:$PATH 

export IRBRC=${SCRIPT_PATH}/irbrc