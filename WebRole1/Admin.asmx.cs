using CrawlerWorker;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Queue;
using Microsoft.WindowsAzure.Storage.Table;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;

namespace WebRole1
{
    [WebService(Namespace = "http://info344crawl.azurewebsites.net/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]

    public class Admin : System.Web.Services.WebService
    {
        // Connect to queue storage
        static CloudStorageAccount storageAccount = CloudStorageAccount.Parse(
            CloudConfigurationManager.GetSetting("StorageConnectionString"));
        static CloudQueueClient queueClient = storageAccount.CreateCloudQueueClient();

        // Create the table client.
        static CloudTableClient tableClient = storageAccount.CreateCloudTableClient();
        static CloudTable table;
        static CloudTable errorTable;

        // Queue for commands
        static CloudQueue command = queueClient.GetQueueReference("commands");
        static CloudQueue answers = queueClient.GetQueueReference("answers");

        static string siteUrl = "cnn.com";

        static string guid = "";
        static string state = "Initializing";
        static string queueSize = "";
        static string indexSize = "";
        static string crawledQty = "";

        [WebMethod]
        public void GetState()
        {
            HttpContext.Current.Response.Write(state);
        }

        [WebMethod]
        public void GetGuid()
        {
            table = tableClient.GetTableReference("sites" + guid);
            errorTable = tableClient.GetTableReference("errors" + guid);
        }

        [WebMethod]
        public void StartCrawling(string root)
        {
            siteUrl = root;

            command.CreateIfNotExists();

            CloudQueueMessage startCmd = new CloudQueueMessage("Start Crawling: " + siteUrl);
            command.AddMessage(startCmd);

            Thread t = new Thread(new ThreadStart(GetAnswers));
            t.Start();

            state = "Traversing Sitemap";

            HttpContext.Current.Response.Write("Crawling Started");
        }

        [WebMethod]
        public void StopCrawling()
        {
            command.CreateIfNotExists();

            CloudQueueMessage startCmd = new CloudQueueMessage("Stop Crawling");
            command.AddMessage(startCmd);

            GetGuid();

            state = "Crawling Stopped";

            HttpContext.Current.Response.Write("Crawling Stopping");
        }

        [WebMethod]
        public void GetCPU()
        {
            PerformanceCounter cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            cpuCounter.NextValue();     // Init data point
            Thread.Sleep(1000);         // and wait
            HttpContext.Current.Response.Write(cpuCounter.NextValue().ToString());
        }

        [WebMethod]
        public void GetRAM()
        {
            PerformanceCounter ramCounter = new PerformanceCounter("Memory", "Available MBytes");
            HttpContext.Current.Response.Write(ramCounter.NextValue().ToString());
        }

        public void GetAnswers()
        {
            while (true)
            {
                // Wait for answer
                while (answers.PeekMessage() == null)
                {
                    Thread.Sleep(10);
                }

                // Get the answer
                CloudQueueMessage cloudAnswer = answers.GetMessage();
                if (cloudAnswer != null)
                {
                    if (cloudAnswer.AsString.StartsWith("QS"))
                    {
                        queueSize = cloudAnswer.AsString.Split(new string[] { "QS:" }, StringSplitOptions.None)[1];
                    }
                    else if (cloudAnswer.AsString.StartsWith("CQ"))
                    {
                        crawledQty = cloudAnswer.AsString.Split(new string[] { "CQ:" }, StringSplitOptions.None)[1];
                    }
                    else if (cloudAnswer.AsString.StartsWith("IS"))
                    {
                        indexSize = cloudAnswer.AsString.Split(new string[] { "IS:" }, StringSplitOptions.None)[1];
                    }
                    else if (cloudAnswer.AsString.StartsWith("GUID"))
                    {
                        guid = cloudAnswer.AsString.Split(new string[] { "GUID:" }, StringSplitOptions.None)[1];

                        table = tableClient.GetTableReference("sites" + guid);
                        errorTable = tableClient.GetTableReference("errors" + guid);
                    }
                    else if (cloudAnswer.AsString.StartsWith("Done mapping"))
                    {
                        state = "Crawling URLs";
                    }

                    answers.DeleteMessage(cloudAnswer);
                }
            }
        }

        [WebMethod]
        public void GetQueueSize()
        {
            HttpContext.Current.Response.Write(queueSize);
        }

        [WebMethod]
        public void GetCrawledQty()
        {
            HttpContext.Current.Response.Write(crawledQty);
        }

        [WebMethod]
        public void GetIndexSize()
        {
            HttpContext.Current.Response.Write(indexSize);
        }

        [WebMethod]
        public void GetLastURLs(int limit)
        {
            GetGuid();
            if (table.Exists())
            {
                TableQuery<SiteEntity> query = new TableQuery<SiteEntity>().Take(limit);

                List<string> sites = new List<string>();

                foreach (SiteEntity e in table.ExecuteQuery(query))
                {
                    sites.Add(Base64Decode(e.URL));
                }
                HttpContext.Current.Response.Write(new JavaScriptSerializer().Serialize(sites));
            }
        }

        [WebMethod]
        public void GetErrors()
        {
            GetGuid();
            if (errorTable.Exists())
            {
                TableQuery<ErrorEntity> query = new TableQuery<ErrorEntity>();
                Dictionary<string, string> errors = new Dictionary<string, string>();
                foreach (ErrorEntity e in errorTable.ExecuteQuery(query))
                {
                    errors.Add(Base64Decode(e.URL), Base64Decode(e.Message));
                }
                HttpContext.Current.Response.Write(new JavaScriptSerializer().Serialize(errors));
            }
        }

        [WebMethod]
        public void GetTitle(string url)
        {
            GetGuid();
            if (table.Exists())
            {
                TableQuery<SiteEntity> query = new TableQuery<SiteEntity>()
                    .Where(TableQuery.GenerateFilterCondition("URL", QueryComparisons.Equal, Base64Encode(url))).Take(1);

                string title = "";

                foreach (SiteEntity e in table.ExecuteQuery(query))
                {
                    title = Base64Decode(e.Title);
                }
                HttpContext.Current.Response.Write(title);
            }
        }

        [WebMethod]
        public void GetHeadline(string url)
        {
            GetGuid();
            if (table.Exists())
            {
                TableQuery<SiteEntity> query = new TableQuery<SiteEntity>()
                    .Where(TableQuery.GenerateFilterCondition("URL", QueryComparisons.Equal, Base64Encode(url))).Take(1);

                string title = "";

                foreach (SiteEntity e in table.ExecuteQuery(query))
                {
                    title = Base64Decode(e.Headline);
                }
                HttpContext.Current.Response.Write(title);
            }
        }

        public static string Base64Decode(string base64EncodedData)
        {
            var base64EncodedBytes = System.Convert.FromBase64String(base64EncodedData);
            return System.Text.Encoding.UTF8.GetString(base64EncodedBytes);
        }
        public static string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
    }
}
