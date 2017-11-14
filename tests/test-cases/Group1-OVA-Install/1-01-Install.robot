# Copyright 2017 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  Test 1-01 - Install Test
Resource  ../../resources/Util.robot
Test Timeout  50 minutes
Suite Setup  Setup VIC Product OVA
Suite Teardown  Cleanup VIC Product OVA  %{OVA-NAME}

*** Keywords ***
Setup VIC Product OVA
    Check vCenter
    Install VIC Product OVA  installer/bin/vic-*.ova
    Log  %{OVA_IP}

Run command and Return output
    [Arguments]  ${command}
    ${rc}  ${output}=  Run And Return Rc And Output  ${command}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    [Return]  ${output}

Check service running
    [Arguments]  ${service-name}
    Log To Console  Checking status of ${service-name}...
    ${out}=  Execute Command  systemctl status ${service-name}
    Should Contain  ${out}  Active: active (running)

*** Test Cases ***
Verify OVA services
    Log To Console  \nWaiting for Getting Started Page to Come Up...
    :FOR  ${i}  IN RANGE  10
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"target":"%{TEST_URL}:443","user":"%{TEST_USERNAME}","password":"%{TEST_PASSWORD}"}' https://%{OVA_IP}:9443/register
    \   Exit For Loop If  '200' in '''${out}'''
    \   Sleep  5s
    Log To Console  ${rc}
    Log To Console  ${out}
    Should Contain  ${out}  200

    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p %{OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no %{OVA_USERNAME_ROOT}@%{OVA_IP}

    Open Connection  %{OVA_IP}
    Wait Until Keyword Succeeds  10x  5s  Login  %{OVA_USERNAME_ROOT}  %{OVA_PASSWORD_ROOT}

    Wait Until Keyword Succeeds  10x  20s  Check service running  harbor
    Wait Until Keyword Succeeds  10x  20s  Check service running  admiral
    Wait Until Keyword Succeeds  10x  20s  Check service running  fileserver
    Wait Until Keyword Succeeds  10x  20s  Check service running  engine_installer

    Close connection

Verify VIC engine download and create VCH
    Download VIC engine

    ${vch-name}=  Install VCH  certs=${false}
    ${output}=  Run command and Return output  docker %{VCH-PARAMS} info
    Should Contain  ${output}  Storage Driver: vSphere Integrated Container
    Should Contain  ${output}  Backend Engine: RUNNING

    [Teardown]  Cleanup VCH  ${vch-name}