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
using Aspose.Cells;
using Aspose.Words;
namespace LiNuoMes.Equipment.hs
{
    /// <summary>
    /// GetEquDeviceCRUD 的摘要说明
    /// </summary>
    public class GetEquDeviceCRUD : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";
        string uploadFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\TemporaryFile\\");
        string browsePartsFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\PartsFile\\");
        string browseManualFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\ManualFile\\");
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


            if (Action == "Equ_Detail")
            {
                EquInfo equinfo = new EquInfo();
                equinfo.ID = RequstString("EquID");
                EquInfo result = new EquInfo();
                result = GetEquDetailObj(equinfo, result);  
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "PartsFileUploadify" || Action == "ManuUploadify")
            {
                HttpPostedFile file = System.Web.HttpContext.Current.Request.Files["Filedata"];
                ResultMsg_FileUPload result = new ResultMsg_FileUPload();
                result = doUploadFile(result, file);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "Equ_Add")
            {
                EquInfo dataEntity = new EquInfo();
                //dataEntity.ID = RequstString("ProcId");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceCode = RequstString("DeviceCode");
                dataEntity.DeviceName= RequstString("DeviceName");
                dataEntity.DeviceVendor = RequstString("DeviceVendor");
                dataEntity.DeviceUseDate = RequstString("PmStartDate");
                dataEntity.DevicePartsFile = RequstString("DevicePartsFile");
                dataEntity.DeviceManualFile = RequstString("DeviceManualFile");
                dataEntity.DeviceComment = RequstString("Description");
                dataEntity.UploadedFile = RequstString("UploadedFile");
                dataEntity.UploadedManualFile = RequstString("UploadedManualFile");
                ResultMsg_Equ result = new ResultMsg_Equ();               
                result = addEquDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "Equ_Edit")
            {
                EquInfo dataEntity = new EquInfo();
                dataEntity.ID = RequstString("EquID");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceCode = RequstString("DeviceCode");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.DeviceVendor = RequstString("DeviceVendor");
                dataEntity.DeviceUseDate = RequstString("PmStartDate");
                dataEntity.DevicePartsFile = RequstString("DevicePartsFile");
                dataEntity.DeviceManualFile = RequstString("DeviceManualFile");
                dataEntity.DeviceComment = RequstString("Description");
                dataEntity.UploadedFile = RequstString("UploadedFile");
                dataEntity.UploadedManualFile = RequstString("UploadedManualFile");
                ResultMsg_Equ result = new ResultMsg_Equ();
                result = editEquDataInDB(dataEntity, result); 
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "PartsFileCHECK" || Action == "PartsFileDOWNLOAD")
            {
                string objID = RequstString("ObjID");
                string fileName = GetEquPartsFileNameFromDB(objID);
                string fileType = Path.GetExtension(fileName).ToLower();
                string fileWithoutType = Path.GetFileNameWithoutExtension(fileName);
                if (!Directory.Exists(browsePartsFilePath))
                {
                    Directory.CreateDirectory(browsePartsFilePath);
                }

                context.Response.ClearContent();
                context.Response.ClearHeaders();
                if (Action == "PartsFileCHECK")
                {
                    //context.Response.AppendHeader("Content-Disposition", string.Format("inline;filename={0}", fileName));
                    if (fileType == ".xlsx" || fileType == ".xls")
                    {
                        string path = browsePartsFilePath + Common.StringFilter.FilterSpecial(fileName);
                        try
                        {
                            Workbook wb = new Workbook(path);
                            wb.Save(browsePartsFilePath + fileWithoutType + ".pdf",Aspose.Cells.SaveFormat.Pdf);
                            context.Response.Write("./PartsFile/" + fileWithoutType + ".pdf");
                        }
                        catch (Exception ex)
                        {
                            context.Response.Write("false");
                        }
                    }
                    else
                    {
                        context.Response.Write("./PartsFile/" + fileWithoutType + ".pdf");
                    }
                    
                }
                else
                {
                    context.Response.AppendHeader("Content-Disposition", string.Format("attached;filename={0}", HttpContext.Current.Server.UrlEncode(fileName.ToString())));
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
                    context.Response.ContentType = "application/octet-stream";
                    context.Response.ContentEncoding = System.Text.Encoding.Default;
                    try
                    {

                        FileInfo fileInfo = new FileInfo(browsePartsFilePath + Common.StringFilter.FilterSpecial(fileName));
                        context.Response.AddHeader("content-length", fileInfo.Length.ToString());//文件大小
                        context.Response.WriteFile(browsePartsFilePath + Common.StringFilter.FilterSpecial(fileName));
                    }
                    catch (Exception ex)
                    {
                        context.Response.Write(ex.Message);
                    }
                    context.Response.Flush();
                    context.Response.Close();
                }

               
            }

            else if (Action == "ManuCHECK" || Action == "ManuDOWNLOAD")
            {
                string objID = RequstString("ObjID");
                string fileName = GetEquManuFileNameFromDB(objID);
                string fileType = Path.GetExtension(fileName).ToLower();
                FileInfo fileInfo = new FileInfo(browseManualFilePath + fileName);
                string fileWithoutType = Path.GetFileNameWithoutExtension(fileName);
                if (!Directory.Exists(browsePartsFilePath))
                {
                    Directory.CreateDirectory(browsePartsFilePath);
                }

                context.Response.ClearContent();
                context.Response.ClearHeaders();
                if (Action == "ManuCHECK")
                {
                    if (fileType == ".docx" || fileType == ".doc")
                    {
                        string path = browseManualFilePath + Common.StringFilter.FilterSpecial(fileName);
                        try
                        {
                            //读取doc文档
                            Document doc = new Document(path);
                            ////保存为PDF文件，此处的SaveFormat支持很多种格式，如图片，epub,rtf 等等
                            doc.Save(browseManualFilePath + fileWithoutType + ".pdf",Aspose.Words.SaveFormat.Pdf);
                            //Workbook wb = new Workbook(path);
                            //wb.Save(browseManualFilePath + fileWithoutType + ".pdf", SaveFormat.Pdf);
                            context.Response.Write("./ManualFile/" + fileWithoutType + ".pdf");
                        }
                        catch (Exception ex)
                        {
                            context.Response.Write("false");
                        }
                    }
                    else
                    {
                        context.Response.Write("./ManualFile/" + fileWithoutType + ".pdf");
                    }
                    
                }
                else
                {
                    //context.Response.AppendHeader("Content-Disposition", string.Format("attached;filename={0}", fileName));
                    //context.Response.AddHeader("content-length", fileInfo.Length.ToString());//文件大小
                    context.Response.AppendHeader("Content-Disposition", string.Format("attached;filename={0}", HttpContext.Current.Server.UrlEncode(fileName.ToString())));
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
                        if (!Directory.Exists(browseManualFilePath))
                        {
                            Directory.CreateDirectory(browseManualFilePath);
                        }
                        FileInfo fileInfo1 = new FileInfo(browseManualFilePath + fileName);
                        context.Response.AddHeader("content-length", fileInfo1.Length.ToString());//文件大小
                        context.Response.WriteFile(browseManualFilePath + fileName);
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

        public EquInfo GetEquDetailObj(EquInfo equinfo, EquInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select ID,ProcessCode,DeviceCode,DeviceName,DeviceVendor,convert(varchar(10),DeviceUseDate,23) as DeviceUseDate,DevicePartsFile,DeviceManualFile,DeviceComment from Equ_DeviceInfoList";
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
                    result.DeviceCode = dt.Rows[0]["DeviceCode"].ToString();
                    result.DeviceName = dt.Rows[0]["DeviceName"].ToString();
                    //result.ProcessName = dt.Rows[0]["ProcessName"].ToString();
                    result.DeviceVendor = dt.Rows[0]["DeviceVendor"].ToString();
                    result.DeviceUseDate = dt.Rows[0]["DeviceUseDate"].ToString();
                    result.DevicePartsFile = dt.Rows[0]["DevicePartsFile"].ToString();
                    result.DeviceManualFile = dt.Rows[0]["DeviceManualFile"].ToString();
                    result.DeviceComment = dt.Rows[0]["DeviceComment"].ToString();
                    
                }
               
            }
            return result;
        }

        public ResultMsg_Equ addEquDataInDB(EquInfo dataEntity, ResultMsg_Equ result)
        {
            if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            if (dataEntity.DeviceCode.Length == 0) dataEntity.DeviceCode = "";
            if (dataEntity.DeviceName.Length == 0) dataEntity.DeviceName = "";
            if (dataEntity.DeviceUseDate.Length == 0) dataEntity.DeviceUseDate = "";
            if (dataEntity.DeviceVendor.Length == 0) dataEntity.DeviceVendor = "";
            if (dataEntity.DevicePartsFile.Length == 0) dataEntity.DevicePartsFile = "";
            if (dataEntity.DeviceManualFile.Length == 0) dataEntity.DeviceManualFile = "";
            if (dataEntity.DeviceComment.Length == 0) dataEntity.DeviceComment = "";

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = " SELECT COUNT(1) AS SM FROM Equ_DeviceInfoList WHERE DeviceCode = '" + dataEntity.DeviceCode + "' ";
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
                            result.msg = "此设备编号已经存在, 请核对!";
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
                             @" INSERT INTO Equ_DeviceInfoList  
                        (  ProcessCode, DeviceCode, DeviceName, DeviceVendor, DeviceUseDate, DevicePartsFile,DeviceManualFile,DeviceComment, UpdateUser, UpdateTime) VALUES (
                          '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}',getdate()) ",
                                 dataEntity.ProcessCode,
                                 dataEntity.DeviceCode,
                                 dataEntity.DeviceName,
                                 dataEntity.DeviceVendor,
                                 dataEntity.DeviceUseDate,
                                 dataEntity.DevicePartsFile,
                                 dataEntity.DeviceManualFile,
                                 dataEntity.DeviceComment,
                                 UserName
                             );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();

                        string strFileMoveResult = "", strFileMoveResult1="";
                        strFileMoveResult = doManualFileMove(dataEntity.UploadedFile, dataEntity.DeviceCode);
                        strFileMoveResult1 = doPartsFileMove(dataEntity.UploadedManualFile,dataEntity.DeviceCode);
                        if (strFileMoveResult.Length == 0 && strFileMoveResult1.Length == 0)
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

        public ResultMsg_Equ editEquDataInDB(EquInfo dataEntity, ResultMsg_Equ result)
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

                    string strSql = " SELECT COUNT(1) AS SM FROM Equ_DeviceInfoList WHERE DeviceCode = '" + dataEntity.DeviceCode + "' and ID <> " + dataEntity.ID;
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
                            result.msg = "此设备编号已经存在, 请核对!";
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
                                                @" UPDATE Equ_DeviceInfoList SET 
                                                  ProcessCode  = '{0}' 
                                                , DeviceCode  = '{1}'
                                                , DeviceName  = '{2}'
                                                , DeviceVendor  = '{3}'
                                                , DeviceUseDate = {4}
                                                , DevicePartsFile= '{5}'
                                                , DeviceManualFile= '{6}'
                                                , DeviceComment= '{7}'
                                                , UpdateUser   = '{8}'
                                                , UpdateTime   = getdate()
                                                WHERE id = {9}
                                            ",
                                                    dataEntity.ProcessCode,
                                                    dataEntity.DeviceCode,
                                                    dataEntity.DeviceName,
                                                    dataEntity.DeviceVendor,
                                                    dataEntity.DeviceUseDate,
                                                    dataEntity.DevicePartsFile,
                                                    dataEntity.DeviceManualFile,
                                                    dataEntity.DeviceComment,
                                                    UserName,
                                                    dataEntity.ID
                                    );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();

                        string strFileMoveResult = "", strFileMoveResult1="";
                        strFileMoveResult = doManualFileMove(dataEntity.UploadedFile, dataEntity.DeviceCode);
                        strFileMoveResult1 = doPartsFileMove(dataEntity.UploadedManualFile,dataEntity.DeviceCode);
                        if (strFileMoveResult.Length == 0 && strFileMoveResult1.Length == 0)
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

        public ResultMsg_FileUPload doUploadFile(ResultMsg_FileUPload result, HttpPostedFile file)
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

        public string doPartsFileMove(string uploadedFileName, string deviceCode)
        {
            string strReturn = "";
            try
            {
                string fileType = Path.GetExtension(uploadedFileName).ToLower();
                string targetFileName = deviceCode + fileType;
                if (uploadedFileName.Length > 0)
                {
                    if (!Directory.Exists(browsePartsFilePath))
                    {
                        Directory.CreateDirectory(browsePartsFilePath);
                    }
                    if (File.Exists(browsePartsFilePath + Common.StringFilter.FilterSpecial(targetFileName)))
                    {
                        File.Delete(browsePartsFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                    }
                    File.Move(uploadFilePath + uploadedFileName, browsePartsFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                }
            }
            catch (Exception e)
            {
                strReturn = e.Message;
            }
            return strReturn;
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
                    if (!Directory.Exists(browseManualFilePath))
                    {
                        Directory.CreateDirectory(browseManualFilePath);
                    }
                    if (File.Exists(browseManualFilePath + Common.StringFilter.FilterSpecial(targetFileName)))
                    {
                        File.Delete(browseManualFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                    }
                    File.Move(uploadFilePath + uploadedFileName, browseManualFilePath + Common.StringFilter.FilterSpecial(targetFileName));
                }
            }
            catch (Exception e)
            {
                strReturn = e.Message;
            }
            return strReturn;
        }

        //得到硬件组成明细表文件
        public string GetEquPartsFileNameFromDB(string objID)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str = " select top 1 DeviceCode, DevicePartsFile from Equ_DeviceInfoList ";
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
                    ReturnValue = dt.Rows[0]["DeviceCode"].ToString() + Path.GetExtension(dt.Rows[0]["DevicePartsFile"].ToString());
                }
            }

            //    ReturnValue = "./ProcessManual/" + ReturnValue + Path.GetExtension(dt.Rows[0]["ProcessManual"].ToString());
            return ReturnValue;
        }

        //得到设备操作说明
        public string GetEquManuFileNameFromDB(string objID)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str = " select top 1 DeviceCode, DeviceManualFile from Equ_DeviceInfoList ";
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
                    ReturnValue = dt.Rows[0]["DeviceCode"].ToString() + Path.GetExtension(dt.Rows[0]["DeviceManualFile"].ToString());
                }
            }

            return ReturnValue;
        }
    }
    public class EquInfo
    {
        public string ID { get; set; }
        public string ProcessCode { set; get; }
        //public string ProcessName { set; get; }
        public string DeviceCode { set; get; }
        public string DeviceName { set; get; }
        public string DeviceVendor { set; get; }
        public string DeviceUseDate { set; get; }

        public string DevicePartsFile { set; get; }
        public string DeviceManualFile { set; get; }
        public string DeviceComment { set; get; }
        public string UploadedFile { set; get; }

        public string UploadedManualFile { set; get; }

    }

    public class ResultMsg_Equ
    {
        public string result { set; get; }
        public string msg { set; get; }
        public EquInfo data { set; get; }
    }

    public class ResultMsg_FileUPload
    {
        public string result { set; get; }
        public string msg { set; get; }
        public string sourceFileName { set; get; }
        public string targetFileName { set; get; }
    }
}