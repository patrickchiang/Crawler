<?xml version="1.0" encoding="utf-8"?>
<serviceModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" name="Crawler" generation="1" functional="0" release="0" Id="9bbf2ac5-6a65-4d48-9aad-f26cc306fca9" dslVersion="1.2.0.0" xmlns="http://schemas.microsoft.com/dsltools/RDSM">
  <groups>
    <group name="CrawlerGroup" generation="1" functional="0" release="0">
      <componentports>
        <inPort name="WorkerAPI:Endpoint1" protocol="http">
          <inToChannel>
            <lBChannelMoniker name="/Crawler/CrawlerGroup/LB:WorkerAPI:Endpoint1" />
          </inToChannel>
        </inPort>
      </componentports>
      <settings>
        <aCS name="CrawlerWorker:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" defaultValue="">
          <maps>
            <mapMoniker name="/Crawler/CrawlerGroup/MapCrawlerWorker:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" />
          </maps>
        </aCS>
        <aCS name="CrawlerWorkerInstances" defaultValue="[1,1,1]">
          <maps>
            <mapMoniker name="/Crawler/CrawlerGroup/MapCrawlerWorkerInstances" />
          </maps>
        </aCS>
        <aCS name="WorkerAPI:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" defaultValue="">
          <maps>
            <mapMoniker name="/Crawler/CrawlerGroup/MapWorkerAPI:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" />
          </maps>
        </aCS>
        <aCS name="WorkerAPIInstances" defaultValue="[1,1,1]">
          <maps>
            <mapMoniker name="/Crawler/CrawlerGroup/MapWorkerAPIInstances" />
          </maps>
        </aCS>
      </settings>
      <channels>
        <lBChannel name="LB:WorkerAPI:Endpoint1">
          <toPorts>
            <inPortMoniker name="/Crawler/CrawlerGroup/WorkerAPI/Endpoint1" />
          </toPorts>
        </lBChannel>
      </channels>
      <maps>
        <map name="MapCrawlerWorker:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" kind="Identity">
          <setting>
            <aCSMoniker name="/Crawler/CrawlerGroup/CrawlerWorker/Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" />
          </setting>
        </map>
        <map name="MapCrawlerWorkerInstances" kind="Identity">
          <setting>
            <sCSPolicyIDMoniker name="/Crawler/CrawlerGroup/CrawlerWorkerInstances" />
          </setting>
        </map>
        <map name="MapWorkerAPI:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" kind="Identity">
          <setting>
            <aCSMoniker name="/Crawler/CrawlerGroup/WorkerAPI/Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" />
          </setting>
        </map>
        <map name="MapWorkerAPIInstances" kind="Identity">
          <setting>
            <sCSPolicyIDMoniker name="/Crawler/CrawlerGroup/WorkerAPIInstances" />
          </setting>
        </map>
      </maps>
      <components>
        <groupHascomponents>
          <role name="CrawlerWorker" generation="1" functional="0" release="0" software="C:\Users\Patrick\documents\visual studio 2013\Projects\Crawler\Crawler\csx\Debug\roles\CrawlerWorker" entryPoint="base\x64\WaHostBootstrapper.exe" parameters="base\x64\WaWorkerHost.exe " memIndex="1792" hostingEnvironment="consoleroleadmin" hostingEnvironmentVersion="2">
            <settings>
              <aCS name="Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" defaultValue="" />
              <aCS name="__ModelData" defaultValue="&lt;m role=&quot;CrawlerWorker&quot; xmlns=&quot;urn:azure:m:v1&quot;&gt;&lt;r name=&quot;CrawlerWorker&quot; /&gt;&lt;r name=&quot;WorkerAPI&quot;&gt;&lt;e name=&quot;Endpoint1&quot; /&gt;&lt;/r&gt;&lt;/m&gt;" />
            </settings>
            <resourcereferences>
              <resourceReference name="DiagnosticStore" defaultAmount="[4096,4096,4096]" defaultSticky="true" kind="Directory" />
              <resourceReference name="EventStore" defaultAmount="[1000,1000,1000]" defaultSticky="false" kind="LogStore" />
            </resourcereferences>
          </role>
          <sCSPolicy>
            <sCSPolicyIDMoniker name="/Crawler/CrawlerGroup/CrawlerWorkerInstances" />
            <sCSPolicyUpdateDomainMoniker name="/Crawler/CrawlerGroup/CrawlerWorkerUpgradeDomains" />
            <sCSPolicyFaultDomainMoniker name="/Crawler/CrawlerGroup/CrawlerWorkerFaultDomains" />
          </sCSPolicy>
        </groupHascomponents>
        <groupHascomponents>
          <role name="WorkerAPI" generation="1" functional="0" release="0" software="C:\Users\Patrick\documents\visual studio 2013\Projects\Crawler\Crawler\csx\Debug\roles\WorkerAPI" entryPoint="base\x64\WaHostBootstrapper.exe" parameters="base\x64\WaIISHost.exe " memIndex="1792" hostingEnvironment="frontendadmin" hostingEnvironmentVersion="2">
            <componentports>
              <inPort name="Endpoint1" protocol="http" portRanges="80" />
            </componentports>
            <settings>
              <aCS name="Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" defaultValue="" />
              <aCS name="__ModelData" defaultValue="&lt;m role=&quot;WorkerAPI&quot; xmlns=&quot;urn:azure:m:v1&quot;&gt;&lt;r name=&quot;CrawlerWorker&quot; /&gt;&lt;r name=&quot;WorkerAPI&quot;&gt;&lt;e name=&quot;Endpoint1&quot; /&gt;&lt;/r&gt;&lt;/m&gt;" />
            </settings>
            <resourcereferences>
              <resourceReference name="DiagnosticStore" defaultAmount="[4096,4096,4096]" defaultSticky="true" kind="Directory" />
              <resourceReference name="EventStore" defaultAmount="[1000,1000,1000]" defaultSticky="false" kind="LogStore" />
            </resourcereferences>
          </role>
          <sCSPolicy>
            <sCSPolicyIDMoniker name="/Crawler/CrawlerGroup/WorkerAPIInstances" />
            <sCSPolicyUpdateDomainMoniker name="/Crawler/CrawlerGroup/WorkerAPIUpgradeDomains" />
            <sCSPolicyFaultDomainMoniker name="/Crawler/CrawlerGroup/WorkerAPIFaultDomains" />
          </sCSPolicy>
        </groupHascomponents>
      </components>
      <sCSPolicy>
        <sCSPolicyUpdateDomain name="WorkerAPIUpgradeDomains" defaultPolicy="[5,5,5]" />
        <sCSPolicyUpdateDomain name="CrawlerWorkerUpgradeDomains" defaultPolicy="[5,5,5]" />
        <sCSPolicyFaultDomain name="CrawlerWorkerFaultDomains" defaultPolicy="[2,2,2]" />
        <sCSPolicyFaultDomain name="WorkerAPIFaultDomains" defaultPolicy="[2,2,2]" />
        <sCSPolicyID name="CrawlerWorkerInstances" defaultPolicy="[1,1,1]" />
        <sCSPolicyID name="WorkerAPIInstances" defaultPolicy="[1,1,1]" />
      </sCSPolicy>
    </group>
  </groups>
  <implements>
    <implementation Id="471f0120-8eba-4235-8181-0bcf26ca7908" ref="Microsoft.RedDog.Contract\ServiceContract\CrawlerContract@ServiceDefinition">
      <interfacereferences>
        <interfaceReference Id="f06e374e-3bb7-4f54-ad88-0f03df9c0c78" ref="Microsoft.RedDog.Contract\Interface\WorkerAPI:Endpoint1@ServiceDefinition">
          <inPort>
            <inPortMoniker name="/Crawler/CrawlerGroup/WorkerAPI:Endpoint1" />
          </inPort>
        </interfaceReference>
      </interfacereferences>
    </implementation>
  </implements>
</serviceModel>