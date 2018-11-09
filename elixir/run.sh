mix escript.build
if [ $? -ne 0 ]; then
  exit;
fi
./api_test word