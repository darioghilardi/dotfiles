# Wrapper to format files with Alejandra since Zed requires stdout
alejandra ${args[0]}
cat ${args[0]}
