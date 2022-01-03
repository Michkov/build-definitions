# local dev build script

if [  -z "$MY_QUAY_USER" ]; then
    echo "MY_QUAY_USER is not set, skip this build."
    exit 0
fi
if [ "$MY_QUAY_USER" = "redhat-appstudio" ]; then
    echo "Cannot use devmode as redhat-appstudio user "
    exit 1  
fi
BUILD_TAG=$(date +"%Y-%m-%d-%H%M%S") 
IMG="quay.io/$MY_QUAY_USER/appstudio-utils:$BUILD_TAG"
echo "Using $MY_QUAY_USER to push results "
docker build -t $IMG .
docker push $IMG

for TASK in util-tasks/*.yaml ; do
    echo $TASK
    cat $TASK | 
        yq -M e ".spec.steps[0].image=\"$IMG\"" - | \
        oc apply -f - 
done 
