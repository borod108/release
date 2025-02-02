#!/bin/bash

set -euo pipefail

trap 'CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi' TERM

INSTANCE_PREFIX="${NAMESPACE}"-"${JOB_NAME_HASH}"
GOOGLE_PROJECT_ID="$(< ${CLUSTER_PROFILE_DIR}/openshift_gcp_project)"
GOOGLE_COMPUTE_REGION="${LEASED_RESOURCE}"
GOOGLE_COMPUTE_ZONE="$(< ${SHARED_DIR}/openshift_gcp_compute_zone)"
if [[ -z "${GOOGLE_COMPUTE_ZONE}" ]]; then
  echo "Expected \${SHARED_DIR}/openshift_gcp_compute_zone to contain the GCP zone"
  exit 1
fi

mkdir -p "${HOME}"/.ssh

mock-nss.sh

# gcloud compute will use this key rather than create a new one
cp "${CLUSTER_PROFILE_DIR}"/ssh-privatekey "${HOME}"/.ssh/google_compute_engine
chmod 0600 "${HOME}"/.ssh/google_compute_engine
cp "${CLUSTER_PROFILE_DIR}"/ssh-publickey "${HOME}"/.ssh/google_compute_engine.pub
echo 'ServerAliveInterval 30' | tee -a "${HOME}"/.ssh/config
echo 'ServerAliveCountMax 1200' | tee -a "${HOME}"/.ssh/config
chmod 0600 "${HOME}"/.ssh/config

# Copy pull secret to user home
cp "${CLUSTER_PROFILE_DIR}"/pull-secret "${HOME}"/pull-secret

gcloud auth activate-service-account --quiet --key-file "${CLUSTER_PROFILE_DIR}"/gce.json
gcloud --quiet config set project "${GOOGLE_PROJECT_ID}"
gcloud --quiet config set compute/zone "${GOOGLE_COMPUTE_ZONE}"
gcloud --quiet config set compute/region "${GOOGLE_COMPUTE_REGION}"


cat <<'EOF' > "${HOME}"/suite.txt
"[k8s.io] Variable Expansion should allow substituting values in a volume subpath [sig-storage] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-api-machinery] ResourceQuota should create a ResourceQuota and capture the life of a persistent volume claim. [sig-storage] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-api-machinery] ResourceQuota should create a ResourceQuota and capture the life of a persistent volume claim with a storage class. [sig-storage] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] ConfigMap binary data should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap optional updates should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume as non-root [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume as non-root with defaultMode and fsGroup set [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume as non-root with FSGroup [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume with defaultMode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume with mappings and Item mode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume with mappings as non-root [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume with mappings as non-root with FSGroup [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable from pods in volume with mappings [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be consumable in multiple volumes in the same pod [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] ConfigMap should be immutable if `immutable` field is set [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] ConfigMap updates should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] CSI Volumes [Driver: csi-hostpath] [Testpattern: Dynamic PV (block volmode)] volume-expand should not allow expansion of pvcs without AllowVolumeExpansion property [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] CSI Volumes [Driver: csi-hostpath] [Testpattern: Dynamic PV (default fs)] volume-expand should not allow expansion of pvcs without AllowVolumeExpansion property [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Downward API volume should provide container's cpu limit [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should provide container's cpu request [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should provide container's memory limit [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should provide container's memory request [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should provide node allocatable (cpu) as default cpu limit if the limit is not set [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should provide node allocatable (memory) as default memory limit if the limit is not set [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should provide podname as non-root with fsgroup and defaultMode [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Downward API volume should provide podname as non-root with fsgroup [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Downward API volume should provide podname only [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should set DefaultMode on files [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should set mode on item file [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should update annotations on modification [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Downward API volume should update labels on modification [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Dynamic Provisioning [k8s.io] GlusterDynamicProvisioner should create and delete persistent volumes [fast] [Skipped:ibmcloud] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes pod should support memory backed volumes of specified size [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes pod should support shared volumes between containers [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (non-root,0644,default) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (non-root,0644,tmpfs) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (non-root,0666,default) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (non-root,0666,tmpfs) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (non-root,0777,default) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (non-root,0777,tmpfs) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (root,0644,default) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (root,0644,tmpfs) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (root,0666,default) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (root,0666,tmpfs) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (root,0777,default) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes should support (root,0777,tmpfs) [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes volume on default medium should have the correct mode [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes volume on tmpfs should have the correct mode [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir volumes when FSGroup is specified [LinuxOnly] [NodeFeature:FSGroup] files with FSGroup ownership should support (root,0644,tmpfs) [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes when FSGroup is specified [LinuxOnly] [NodeFeature:FSGroup] new files should be created with FSGroup ownership when container is non-root [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes when FSGroup is specified [LinuxOnly] [NodeFeature:FSGroup] new files should be created with FSGroup ownership when container is root [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes when FSGroup is specified [LinuxOnly] [NodeFeature:FSGroup] nonexistent volume subPath should have the correct mode and owner using FSGroup [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes when FSGroup is specified [LinuxOnly] [NodeFeature:FSGroup] volume on default medium should have the correct mode using FSGroup [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir volumes when FSGroup is specified [LinuxOnly] [NodeFeature:FSGroup] volume on tmpfs should have the correct mode using FSGroup [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] EmptyDir wrapper volumes should not cause race condition when used for configmaps [Serial] [Conformance] [Suite:openshift/conformance/serial/minimal] [Suite:k8s]"
"[sig-storage] EmptyDir wrapper volumes should not conflict [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Ephemeralstorage When pod refers to non-existent ephemeral storage should allow deletion of pod with invalid volume : configmap [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Ephemeralstorage When pod refers to non-existent ephemeral storage should allow deletion of pod with invalid volume : projected [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Ephemeralstorage When pod refers to non-existent ephemeral storage should allow deletion of pod with invalid volume : secret [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] HostPath should give a volume the correct mode [LinuxOnly] [NodeConformance] [Skipped:ibmcloud] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] HostPath should support r/w [NodeConformance] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should be able to unmount after the subpath directory is deleted [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should support existing directory [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should support existing single file [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should support file as subpath [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should support non-existent path [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should support readOnly directory specified in the volumeMount [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] subPath should support readOnly file specified in the volumeMount [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] volumes should allow exec of files on the volume [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: emptydir] [Testpattern: Inline-volume (default fs)] volumes should store data [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: gluster] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Skipped:ibmcloud] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: hostPathSymlink] [Testpattern: Inline-volume (default fs)] volumes should store data [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: hostPath] [Testpattern: Inline-volume (default fs)] volumes should store data [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: blockfs] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: block] [Testpattern: Pre-provisioned PV (block volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: block] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: dir-bindmounted] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: dir-link-bindmounted] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: dir-link] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: dir] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: local][LocalVolumeType: tmpfs] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: nfs] [Testpattern: Dynamic PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] In-tree Volumes [Driver: nfs] [Testpattern: Pre-provisioned PV (filesystem volmode)] volumeMode should not mount / map unused volumes in a pod [LinuxOnly] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Managed cluster should have no crashlooping recycler pods over four minutes [Suite:openshift/conformance/parallel]"
"[sig-storage] PersistentVolumes-local  Pods sharing a single local PV [Serial] all pods should be running [Suite:openshift/conformance/serial] [Suite:k8s]"
"[sig-storage] Projected combined should project all components that make up the projection API [Projection][NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap optional updates should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume as non-root [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume as non-root with defaultMode and fsGroup set [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume as non-root with FSGroup [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume with defaultMode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume with mappings and Item mode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume with mappings as non-root [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume with mappings as non-root with FSGroup [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable from pods in volume with mappings [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap should be consumable in multiple volumes in the same pod [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected configMap updates should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide container's cpu limit [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide container's cpu request [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide container's memory limit [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide container's memory request [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide node allocatable (cpu) as default cpu limit if the limit is not set [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide node allocatable (memory) as default memory limit if the limit is not set [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide podname as non-root with fsgroup and defaultMode [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide podname as non-root with fsgroup [LinuxOnly] [NodeFeature:FSGroup] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should provide podname only [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should set DefaultMode on files [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should set mode on item file [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should update annotations on modification [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected downwardAPI should update labels on modification [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret optional updates should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret should be able to mount in a volume regardless of a different secret existing with same name in different namespace [NodeConformance] [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Projected secret should be consumable from pods in volume as non-root with defaultMode and fsGroup set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret should be consumable from pods in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret should be consumable from pods in volume with defaultMode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret should be consumable from pods in volume with mappings and Item Mode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret should be consumable from pods in volume with mappings [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Projected secret should be consumable in multiple volumes in a pod [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] PV Protection Verify \"immediate\" deletion of a PV that is not bound to a PVC [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] PV Protection Verify that PV bound to a PVC is not removed immediately [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Secrets optional updates should be reflected in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be able to mount in a volume regardless of a different secret existing with same name in different namespace [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be consumable from pods in volume as non-root with defaultMode and fsGroup set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be consumable from pods in volume [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be consumable from pods in volume with defaultMode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be consumable from pods in volume with mappings and Item Mode set [LinuxOnly] [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be consumable from pods in volume with mappings [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be consumable in multiple volumes in a pod [NodeConformance] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Secrets should be immutable if `immutable` field is set [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Subpath Atomic writer volumes should support subpaths with configmap pod [LinuxOnly] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Subpath Atomic writer volumes should support subpaths with configmap pod with mountPath of existing file [LinuxOnly] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Subpath Atomic writer volumes should support subpaths with downward pod [LinuxOnly] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Subpath Atomic writer volumes should support subpaths with projected pod [LinuxOnly] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Subpath Atomic writer volumes should support subpaths with secret pod [LinuxOnly] [Conformance] [Suite:openshift/conformance/parallel/minimal] [Suite:k8s]"
"[sig-storage] Subpath Container restart should verify that container can restart successfully after configmaps modified [Suite:openshift/conformance/parallel] [Suite:k8s]"
"[sig-storage] Volumes ConfigMap should be mountable [Suite:openshift/conformance/parallel] [Suite:k8s]"
EOF
chmod +r "${HOME}"/suite.txt

# scp and install microshift.service
  LD_PRELOAD=/usr/lib64/libnss_wrapper.so gcloud compute scp \
  --quiet \
  --project "${GOOGLE_PROJECT_ID}" \
  --zone "${GOOGLE_COMPUTE_ZONE}" \
  --recurse "${HOME}"/suite.txt rhel8user@"${INSTANCE_PREFIX}":~/suite.txt

