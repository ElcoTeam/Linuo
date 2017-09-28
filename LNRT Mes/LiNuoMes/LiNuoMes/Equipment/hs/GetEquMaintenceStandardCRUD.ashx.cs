using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using Aspose.Words;

namespace LiNuoMes.Equipment.hs
{
    /// <summary>
    /// GetEquMaintenceStandardCRUD 的摘要说明
    /// </summary>
    public class GetEquMaintenceStandardCRUD : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";
        string uploadFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\TemporaryFile\\");
        string browsePmSpecFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\PmSpecFile\\");
        
        string UserName = "";

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            if (context.Session["UserName"] != null)
                UserName = context.Session["UserName"].ToString().ToUpper().Trim();
            else
                UserName = "";

            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";

            if (Action == "EquMaintenceStandrad_Detail")
            {
                Equ_PmSpecInfo equinfo = new Equ_PmSpecInfo();
                equinfo.ID = RequstString("EquID");
                Equ_PmSpecInfo result = new Equ_PmSpecInfo();
                result = GetEquDetailObj(equinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "PmSpecFileUploadify")
            {
                HttpPostedFile file = System.Web.HttpContext.Current.Request.Files["Filedata"];
                ResultMsg_PmSpecFileUPload result = new ResultMsg_PmSpecFileUPload();
                result = doUploadFile(result, file);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquMaintenceStandrad_Add")
            {
                Equ_PmSpecInfo dataEntity = new Equ_PmSpecInfo();
                //dataEntity.ID = RequstString("ProcId");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmSpecCode = RequstString("PmSpecCode");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmLevel = RequstString("PmLevel");
                dataEntity.PmSpecFile = RequstString("PmSpecFile");
                dataEntity.UploadedFile = RequstString("UploadedPmSpecFile");
                dataEntity.PmSpecComment = RequstString("PmSpecComment");
                ResultMsg_Equ_PmSpec result = new ResultMsg_Equ_PmSpec();
                result = addEquMaintenceStandradDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquMaintenceStandrad_Edit")
            {
                Equ_PmSpecInfo dataEntity = new Equ_PmSpecInfo();
                dataEntity.ID = RequstString("EquID");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmSpecCode = RequstString("PmSpecCode");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmLevel = RequstString("PmLevel");
                dataEntity.PmSpecFile = RequstString("PmSpecFile");
                dataEntity.UploadedFile = RequstString("UploadedPmSpecFile");

                ResultMsg_Equ_PmSpec result = new ResultMsg_Equ_PmSpec();
                result = editEquMaintenceStandradDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "StandardFileCHECK" || Action == "StandardFileDOWNLOAD" || Action == "PmStandardFileCHECK")
            {
                string objID = RequstString("objID");
                string fileName = string.Empty;
                if (Action == "StandardFileCHECK" || Action == "StandardFileDOWNLOAD")
                {
                    fileName = GetEquStandardFileNameFromDB(objID);
                }
                else
                {
                    fileName = GetEquPmStandardFileNameFromDB(objID);
                }
                string fileType = Path.GetExtension(fileName).ToLower();
                FileInfo fileInfo = new FileInfo(browsePmSpecFilePath + fileName);
                string fileWithoutType = Path.GetFileNameWithoutExtension(fileName);
                if (!Directory.Exists(browsePmSpecFilePath))
                {
                    Directory.CreateDirectory(browsePmSpecFilePath);
                }
                context.Response.ClearContent();
                context.Response.ClearHeaders();
                if (Action == "StandardFileCHECK" || Action == "PmStandardFileCHECK")
                {
                    if (fileType == ".docx" || fileType == ".doc")
                    {
                        string path = browsePmSpecFilePath + Common.StringFilter.FilterSpecial(fileName);
                        try
                        {
                            //读取doc文档
                            Document doc = new Document(path);
                            ////保存为PDF文件，此处的SaveFormat支持很多种格式，如图片，epub,rtf 等等
                            doc.Save(browsePmSpecFilePath + fileWithoutType + ".pdf", Aspose.Words.SaveFormat.Pdf);
                            //Workbook wb = new Workbook(path);
                            //wb.Save(browseManualFilePath + fileWithoutType + ".pdf", SaveFormat.Pdf);
                            context.Response.Write("./PmSpecFile/" + fileWithoutType + ".pdf");
                            
                        }
                        catch (Exception ex)
                        {
                            context.Response.Write("false");
                        }
                    }
                    else
                    {
                        context.Response.Write("./PmSpecFile/" + fileWithoutType + ".pdf");
                    }
                    
                }
                else
                {
                    if (fileType == ".docx" || fileType == ".doc")
                    {
                        context.Response.AppendHeader("content-type", "application/msword");
                    }
                    else if (fileType == ".xlsx" || fileType == ".xls")
                    {
                        context.Response.AppendHeader("content-type", "application/x-msexcel");
                    }
                    else if (fileType == ".pdf")
                    {
                        context.Response.AppendHeader("content-type", "application/pdf");
                    }

                    try
                    {
                        FileInfo fileInfo1 = new FileInfo(browsePmSpecFilePath + Common.StringFilter.FilterSpecial(fileName));
                        context.Response.AddHeader("content-length", fileInfo1.Length.ToString());//文件大小
                        context.Response.WriteFile(browsePmSpecFilePath + Common.StringFilter.FilterSpecial(fileName));
                    }
                    catch (Exception ex)
                    {
                        context.Response.Write(ex.Message);
                    }
                    context.Response.Flush();
                    context.Response.Close();
                    
                }

            }
        }

        public ResultMsg_Equ_PmSpec addEquMaintenceStandradDataInDB(Equ_PmSpecInfo dataEntity, ResultMsg_Equ_PmSpec result)
        {
            if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            if (dataEntity.DeviceName.Length == 0) dataEntity.DeviceName = "";
            if (dataEntity.PmSpecCode.Length == 0) dataEntity.PmSpecCode = "";
            if (dataEntity.PmSpecName.Length == 0) dataEntity.PmSpecName = "";
            if (dataEntity.PmLevel.Length == 0) dataEntity.PmLevel = "";
            if (dataEntity.PmSpecFile.Length == 0) dataEntity.PmSpecFile = "";
            if (dataEntity.PmSpecComment.Length == 0) dataEntity.PmSpecComment = "";

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = " SELECT COUNT(1) AS SM FROM Equ_PmSpecList WHERE PmSpecCode = '" + dataEntity.PmSpecCode + "' ";
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    Datapter.Fill(dt);

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        if (Convert.ToInt32(dt.Rows[0]["SM"]) > 0)
                        {
                            result.result = "failed";
                            result.msg = "此保养规范编号已经存在, 请核对!";
                        }
                        else
                        {
                            result.result = "";
                            result.msg = "";
                        }
                    }
                    else
                    {
                        result.result = "failed";
                        result.msg = "数据重复性检查失败!";
                    }

                    if (result.result == "")
                    {
                        transaction = conn.BeginTransaction();
                        cmd.Transaction = transaction;
                        strSql = string.Format(
                             @" INSERT INTO Equ_PmSpecList  
                        (  ProcessCode, DeviceName, PmSpecCode, PmSpecName, PmLevel,PmSpecFile,PmSpecComment, UpdateUser, UpdateTime) VALUES (
                          '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',getdate()) ",
                                 dataEntity.ProcessCode,
                                 dataEntity.DeviceName,
                                 dataEntity.PmSpecCode,
                                 dataEntity.PmSpecName,
                                 dataEntity.PmLevel,
                                 dataEntity.PmSpecFile,
                                 dataEntity.PmSpecComment,
                                 UserName
                             );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();

                        string strFileMoveResult = "";
                        strFileMoveResult = doManualFileMove(dataEntity.UploadedFile, dataEntity.PmSpecCode);
                        if (strFileMoveResult.Length == 0)
                        {
                            transaction.Commit();
                            result.result = "success";
                            result.msg = "保存数据成功!";
                        }
                        else
                        {
                            transaction.Rollback();
                            result.result = "failed";
                            result.msg = "服务器端文件处理发生错误.\n" + strFileMoveResult;
                        }
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    result.result = "failed";
                    result.msg = "保存失败! \n" + ex.Message;
                }
            }
            return result;
        }

        public ResultMsg_Equ_PmSpec editEquMaintenceStandradDataInDB(Equ_PmSpecInfo dataEntity, ResultMsg_Equ_PmSpec result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            //if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            //if (dataEntity.ProcessName.Length == 0) dataEntity.ProcessName = "";
            //if (dataEntity.ProcessBeat.Length == 0) dataEntity.ProcessBeat = "";
            //if (dataEntity.ProcessDsca.Length == 0) dataEntity.ProcessDsca = "";
            //if (dataEntity.InturnNumber.Length == 0) dataEntity.InturnNumber = "0";
            //if (dataEntity.ProcessManual.Length == 0) dataEntity.ProcessManual = "";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;

                    string strSql = " SELECT COUNT(1) AS SM FROM Equ_PmSpecList WHERE PmSpecCode = '" + dataEntity.PmSpecCode+ "' and ID <> " + dataEntity.ID;
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    Datapter.Fill(dt);

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        if (Convert.ToInt32(dt.Rows[0]["SM"]) > 0)
                        {
                            result.result = "failed";
                            result.msg = "此保养规范编号已经存在, 请核对!";
                        }
                        else
                        {
                            result.result = "";
                            result.msg = "";
                        }
                    }
                    else
                    {
                        result.result = "failed";
                        result.msg = "数据重复性检查失败!";
                    }

                    if (result.result == "")
                    {
                        transaction = conn.BeginTransaction();
                        cmd.Transaction = transaction;
                        strSql = string.Format(
                                                @" UPDATE Equ_PmSpecList SET 
                                                  ProcessCode  = '{0}' 
                                                , DeviceName  = '{1}'
                                                , PmSpecCode  = '{2}'
                                                , PmSpecName = '{3}'
                                                , PmLevel= '{4}'
                                                , PmSpecFile= '{5}'
                                                , PmSpecComment= '{6}'
                                                , UpdateUser   = '{7}'
                                                , UpdateTime   = getdate()
                                                WHERE id = {8}
                                            ",
                                                    dataEntity.ProcessCode,
                                                    dataEntity.DeviceName,
                                                    dataEntity.PmSpecCode,
                                                    dataEntity.PmSpecName,
                                                    dataEntity.PmLevel,
                                                    dataEntity.PmSpecFile,
                                                    dataEntity.PmSpecComment,
                                                    UserName,
                                                    dataEntity.ID
                                    );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();

                        if (dataEntity.UploadedFile != dataEntity.PmSpecFile)
                        {
                            string strFileMoveResult = "";

                            strFileMoveResult = doManualFileMove(dataEntity.UploadedFile, dataEntity.PmSpecCode);
                            if (strFileMoveResult.Length == 0)
                            {
                                transaction.Commit();
                                result.result = "success";
                                result.msg = "保存数据成功!";
                            }
                            else
                            {
                                transaction.Rollback();
                                result.result = "failed";
                                result.msg = "服务器端文件处理发生错误.\n" + strFileMoveResult;
                            }
                        }
                        else
                        {
                            string fileType = Path.GetExtension(dataEntity.PmSpecFile).ToLower();
                            string targetFileName = dataEntity.PmSpecCode + fileType;
                            if (fileType == ".docx" || fileType == ".doc")
                            {

                                //读取doc文档
                                Document doc = new Document(browsePmSpecFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                                ////保存为PDF文件，此处的SaveFormat支持很多种格式，如图片，epub,rtf 等等
                                doc.Save(browsePmSpecFilePath + dataEntity.PmSpecCode + ".pdf", SaveFormat.Pdf);
                            }
                            transaction.Commit();
                            result.result = "success";
                            result.msg = "保存数据成功!";
                        }
                       
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    result.result = "failed";
                    result.msg = "保存失败! \n" + ex.Message;
                }
            }
            return result;
        }

        public Equ_PmSpecInfo GetEquDetailObj(Equ_PmSpecInfo equinfo, Equ_PmSpecInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select * from Equ_PmSpecList";
                if (equinfo.ID != "")
                {
                    str1 += " WHERE ID = " + equinfo.ID + " ";
                }
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    result.ID = dt.Rows[0]["ID"].ToString();
                    result.ProcessCode = dt.Rows[0]["ProcessCode"].ToString();
                    result.DeviceName = dt.Rows[0]["DeviceName"].ToString();
                    result.PmSpecCode = dt.Rows[0]["PmSpecCode"].ToString();
                    result.PmSpecName = dt.Rows[0]["PmSpecName"].ToString();
                    result.PmLevel = dt.Rows[0]["PmLevel"].ToString();
                    result.PmSpecFile = dt.Rows[0]["PmSpecFile"].ToString();
                    result.PmSpecComment = dt.Rows[0]["PmSpecComment"].ToString();
                }
            }
            return result;
        }

        public ResultMsg_PmSpecFileUPload doUploadFile(ResultMsg_PmSpecFileUPload result, HttpPostedFile file)
        {
            //判断文件是否为空               
            if (file != null)
            {
                string fileName = file.FileName;
                string fileType = Path.GetExtension(fileName).ToLower();

                //由于不同浏览器取出的FileName不同（有的是文件绝对路径，有的是只有文件名），故要进行处理
                if (fileName.IndexOf(' ') > -1)
                {
                    fileName = fileName.Substring(fileName.LastIndexOf(' ') + 1);
                }
                else if (fileName.IndexOf('/') > -1)
                {
                    fileName = fileName.Substring(fileName.LastIndexOf('/') + 1);
                }

                if (!Directory.Exists(uploadFilePath))
                {
                    Directory.CreateDirectory(uploadFilePath);
                }
                result.sourceFileName = fileName;
                result.targetFileName = getTemporaryFileName(fileType);

                file.SaveAs(uploadFilePath + result.targetFileName);
                //读取doc文档
                //Document doc = new Document(uploadFilePath + result.targetFileName);
                ////保存为PDF文件，此处的SaveFormat支持很多种格式，如图片，epub,rtf 等等
                //doc.Save(uploadFilePath + result.targetFileName, SaveFormat.Pdf);
                result.result = "success";
                result.msg = "上传成功";
            }
            else
            {
                result.result = "failed";
                result.msg = "上传失败";
                result.sourceFileName = "";
                result.targetFileName = "";
            }
            return result;
        }

        public string getTemporaryFileName(string fileType)
        {
            const int RANDOM_MAX_VALUE = 100000;
            string strTemp, strYear, strMonth, strDay, strHour, strMinute, strSecond, strMillisecond;

            Random rnd = new Random(); //获取一个随机数
            DateTime dt = DateTime.Now;

            int rndNumber = rnd.Next(RANDOM_MAX_VALUE);

            strYear = dt.Year.ToString();
            strMonth = (dt.Month > 9) ? dt.Month.ToString() : "0" + dt.Month.ToString();
            strDay = (dt.Day > 9) ? dt.Day.ToString() : "0" + dt.Day.ToString();
            strHour = (dt.Hour > 9) ? dt.Hour.ToString() : "0" + dt.Hour.ToString();
            strMinute = (dt.Minute > 9) ? dt.Minute.ToString() : "0" + dt.Minute.ToString();
            strSecond = (dt.Second > 9) ? dt.Second.ToString() : "0" + dt.Second.ToString();
            strMillisecond = dt.Millisecond.ToString();

            strTemp = strYear
                + strMonth + "_"
                + strDay + "_"
                + strHour + "_"
                + strMinute + "_"
                + strSecond + "_"
                + strMillisecond + "_"
                + rndNumber.ToString();

            return strTemp + fileType;
        }

        public string doManualFileMove(string uploadedFileName, string deviceCode)
        {
            string strReturn = "";
            try
            {
                string fileType = Path.GetExtension(uploadedFileName).ToLower();
                string targetFileName = deviceCode + fileType;
                if (uploadedFileName.Length > 0)
                {
                    if (!Directory.Exists(browsePmSpecFilePath))
                    {
                        Directory.CreateDirectory(browsePmSpecFilePath);
                    }
                    if (File.Exists(browsePmSpecFilePath + Common.StringFilter.FilterSpecial(targetFileName)))
                    {
                        File.Delete(browsePmSpecFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                    }
                    
                    File.Move(uploadFilePath + uploadedFileName, browsePmSpecFilePath + Common.StringFilter.FilterSpecial( targetFileName));
                    if (fileType == ".docx" || fileType == ".doc")
                    {
                        //读取doc文档
                        Document doc = new Document(browsePmSpecFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                        ////保存为PDF文件，此处的SaveFormat支持很多种格式，如图片，epub,rtf 等等
                        doc.Save(browsePmSpecFilePath + deviceCode + ".pdf", SaveFormat.Pdf);
                    }
                   
                }
            }
            catch (Exception e)
            {
                strReturn = e.Message;
            }
            return strReturn;
        }

        //得到保养规范
        public string GetEquStandardFileNameFromDB(string objID)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str = " select top 1 PmSpecCode, PmSpecFile from Equ_PmSpecList ";
                string strWhere = "";
                if (objID.Length > 0)
                {
                    strWhere = " WHERE ID = " + objID;
                }
                str += strWhere;
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    ReturnValue = dt.Rows[0]["PmSpecCode"].ToString() + Path.GetExtension(dt.Rows[0]["PmSpecFile"].ToString());
                }
            }

            //    ReturnValue = "./ProcessManual/" + ReturnValue + Path.GetExtension(dt.Rows[0]["ProcessManual"].ToString());
            return ReturnValue;
        }

        //得到保养规范
        public string GetEquPmStandardFileNameFromDB(string objID)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str = " select top 1 PmSpecCode, PmSpecFile from Equ_PmSpecList ";
                string strWhere = "";
                if (objID.Length > 0)
                {
                    strWhere = " WHERE ID = '" + objID + "'";
                }
                str += strWhere;
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    ReturnValue = dt.Rows[0]["PmSpecCode"].ToString()+ Path.GetExtension(dt.Rows[0]["PmSpecFile"].ToString());
                }
            }

            //    ReturnValue = "./ProcessManual/" + ReturnValue + Path.GetExtension(dt.Rows[0]["ProcessManual"].ToString());
            return ReturnValue;
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        public static string RequstString(string sParam)
        {
            return (HttpContext.Current.Request[sParam] == null ? string.Empty
                  : HttpContext.Current.Request[sParam].ToString().Trim());
        }
    }

    public class Equ_PmSpecInfo
    {
        public string ID { get; set; }
        public string ProcessCode { set; get; }
        
        public string DeviceName { set; get; }

        public string PmSpecCode { set; get; }
        public string PmSpecName { set; get; }

        public string PmLevel { set; get; }
        public string PmSpecFile { set; get; }
        public string PmSpecComment { set; get; }

        public string UploadedFile { set; get; }

    }

    public class ResultMsg_Equ_PmSpec
    {
        public string result { set; get; }
        public string msg { set; get; }
        public Equ_PmSpecInfo data { set; get; }
    }

    public class ResultMsg_PmSpecFileUPload
    {
        public string result { set; get; }
        public string msg { set; get; }
        public string sourceFileName { set; get; }
        public string targetFileName { set; get; }
    }
}