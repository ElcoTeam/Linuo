using ExportToExcel;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using HtmlAgilityPack;
using System.Text.RegularExpressions;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System.Data.SqlClient;
using System.Configuration;

namespace LiNuoMes.Mfg
{
    /// <summary>
    /// ExportMaterialReportToExcel 的摘要说明
    /// </summary>
    public class ExportMaterialReportToExcel : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            string tabData = context.Request["excelData"];

            //jqgrid table
            DataTable dt = ConvertCsvData(tabData);
            if (dt == null)
            {
                //  Add some error-catching here...
                return;
            }

            string excelFilename = context.Request["filename"];
            string parm1 = context.Request["parm1"];
            string parm2 = context.Request["parm2"];
            string parm3 = context.Request["parm3"];
            string parm4 = context.Request["parm4"];
            string parm5 = context.Request["parm5"];
            
            if (File.Exists(excelFilename))
                File.Delete(excelFilename);

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><body><table><tr><td>工厂:</td><td>" + parm1 + "</td><td>制单人:</td><td>" + parm2 + "</td><td>打印时间:</td><td>" + parm3 + "</td></tr>");
            sb.Append("<tr><td>领料库位:</td><td>" + parm4 + "</td><td>发料库位:</td><td>" + parm5 + "</td></tr></table>");
            sb.Append("</body></html>");
            HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
            doc.LoadHtml(sb.ToString());
            var trReg = new Regex(pattern: @"(?<=(<[t|T][r|R]))[\s\S]*?(?=(</[t|T][r|R]>))");
            var trMatchCollection = trReg.Matches(sb.ToString());

            //表头 table
            DataTable dt1 = new DataTable("data");
            for (int k = 0; k < 14; k++)
            {
                DataColumn dc = new DataColumn();
                dt1.Columns.Add(dc);
            }
            for (int i = 0; i < trMatchCollection.Count; i++)
            {
                var row = "<tr " + trMatchCollection[i].ToString().Trim() + "</tr>";
                var tdReg = new Regex(pattern: @"(?<=(<[t|T][d|D|h|H]))[\s\S]*?(?=(</[t|T][d|D|h|H]>))");
                var tdMatchCollection = tdReg.Matches(row);
                DataRow dr = dt1.NewRow();
                for (int j = 0; j < tdMatchCollection.Count; j++)
                {
                    var tdValue = RemoveHtml("<td " + tdMatchCollection[j].ToString().Trim() + "</td>");
                    dr[j] = tdValue;
                }
                dt1.Rows.Add(dr);
            }


            StringBuilder sb1 = new StringBuilder();
            sb1.Append("<html><body><table><tr><td>保管员:</td><td></td><td>审核:</td><td></td><td>领料员:</td></tr>");
            sb1.Append("</body></html>");
            HtmlAgilityPack.HtmlDocument doc1 = new HtmlAgilityPack.HtmlDocument();
            doc1.LoadHtml(sb.ToString());
            var trReg1 = new Regex(pattern: @"(?<=(<[t|T][r|R]))[\s\S]*?(?=(</[t|T][r|R]>))");
            var trMatchCollection1 = trReg1.Matches(sb1.ToString());

            //表尾  table
            DataTable dtRemark = new DataTable();
            for (int k = 0; k < 14; k++)
            {
                DataColumn dc = new DataColumn();
                dtRemark.Columns.Add(dc);
            }
            for (int i = 0; i < trMatchCollection1.Count; i++)
            {
                var row = "<tr " + trMatchCollection1[i].ToString().Trim() + "</tr>";
                var tdReg = new Regex(pattern: @"(?<=(<[t|T][d|D|h|H]))[\s\S]*?(?=(</[t|T][d|D|h|H]>))");
                var tdMatchCollection1 = tdReg.Matches(row);
                DataRow dr1 = dtRemark.NewRow();

                for (int j = 0; j < tdMatchCollection1.Count; j++)
                {
                    var tdValue = RemoveHtml("<td " + tdMatchCollection1[j].ToString().Trim() + "</td>");
                    dr1[j] = tdValue;

                }
                dtRemark.Rows.Add(dr1);
            }

            DataTable newDataTable = UniteDataTable(dt1, dt, dtRemark);
            ExportDataSetToExcel(newDataTable, excelFilename, context.Response);
            //CreateExcelFile.CreateExcelDocument(dt, excelFilename, context.Response);
        }

        private DataTable ConvertCsvData(string CSVdata)
        {
            //  Convert a tab-separated set of data into a DataTable, ready for our C# CreateExcelFile libraries
            //  to turn into an Excel file.
            //
            DataTable dt = new DataTable();
            try
            {
                System.Diagnostics.Trace.WriteLine(CSVdata);

                string[] Lines = CSVdata.Split(new char[] { '\r', '\n' });
                if (Lines == null)
                    return dt;
                if (Lines.GetLength(0) == 0)
                    return dt;

                string[] HeaderText = Lines[0].Split('\t');

                int numOfColumns = HeaderText.Count();


                foreach (string header in HeaderText)
                    dt.Columns.Add(header, typeof(string));

                DataRow Row;
                for (int i = 1; i < Lines.GetLength(0); i++)
                {
                    string[] Fields = Lines[i].Split('\t');
                    if (Fields.GetLength(0) == numOfColumns)
                    {
                        Row = dt.NewRow();
                        for (int f = 0; f < numOfColumns; f++)
                            Row[f] = Fields[f];
                        dt.Rows.Add(Row);
                    }
                }

                return dt;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine("An exception occurred: " + ex.Message);
                return null;
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        /// <summary>  
        /// 将DataTable导出到Excel  
        /// </summary>  
        /// <param name="dt">DataTable</param>   
        /// <param name="fileName">仅文件名（非路径）</param>   
        /// <returns>返回Excel文件绝对路径</returns>  
        public void ExportDataSetToExcel(DataTable dt, string fileName, System.Web.HttpResponse Response)
        {
            #region 表头
            HSSFWorkbook hssfworkbook = new HSSFWorkbook();

            NPOI.SS.UserModel.ISheet hssfSheet = hssfworkbook.CreateSheet(fileName);
            hssfSheet.DefaultColumnWidth = 10;
            hssfSheet.SetColumnWidth(0, 10 * 256);
            hssfSheet.SetColumnWidth(3, 10 * 256);

            // 表头  
            NPOI.SS.UserModel.IRow tagRow0 = hssfSheet.CreateRow(0);
            tagRow0.Height = 40 * 40;
            ICell cell0 = tagRow0.CreateCell(0);
            //设置单元格内容
            cell0.SetCellValue("力诺瑞特制造工厂");
            hssfSheet.AddMergedRegion(new CellRangeAddress(0, 0, 0, 13));

            NPOI.SS.UserModel.IRow tagRow1 = hssfSheet.CreateRow(1);
            tagRow1.Height = 30 * 20;
            ICell cell1 = tagRow1.CreateCell(0);
            //设置单元格内容
            cell1.SetCellValue("反冲材料补料单");
            hssfSheet.AddMergedRegion(new CellRangeAddress(1, 1, 0, 13));


            NPOI.SS.UserModel.ICellStyle tagStyle = hssfworkbook.CreateCellStyle();
            tagStyle.Alignment = NPOI.SS.UserModel.HorizontalAlignment.Center;
            tagStyle.VerticalAlignment = VerticalAlignment.Center;
            //tagStyle.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            //tagStyle.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            IFont font = hssfworkbook.CreateFont();
            font.FontHeightInPoints = 16;
            font.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;
            font.FontName = "宋体";
            tagStyle.SetFont(font);//HEAD 样式
            cell0.CellStyle = tagStyle;
            NPOI.SS.UserModel.ICellStyle tagStyle1 = hssfworkbook.CreateCellStyle();
            tagStyle1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.Center;
            tagStyle1.VerticalAlignment = VerticalAlignment.Center;
            cell1.CellStyle = tagStyle1;

            // 标题样式  
            NPOI.SS.UserModel.ICellStyle cellStyle1 = hssfworkbook.CreateCellStyle();
            cellStyle1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.Center;
            cellStyle1.VerticalAlignment = VerticalAlignment.Center;
            cellStyle1.BorderBottom = NPOI.SS.UserModel.BorderStyle.None;
            cellStyle1.BorderLeft = NPOI.SS.UserModel.BorderStyle.None;
            cellStyle1.BorderRight = NPOI.SS.UserModel.BorderStyle.None;
            cellStyle1.BorderTop = NPOI.SS.UserModel.BorderStyle.None;
            #endregion

            //数据样式
            NPOI.SS.UserModel.ICellStyle cellStyle = hssfworkbook.CreateCellStyle();
            cellStyle.Alignment = NPOI.SS.UserModel.HorizontalAlignment.Center;
            cellStyle.VerticalAlignment = VerticalAlignment.Center;
            cellStyle.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cellStyle.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cellStyle.BottomBorderColor = NPOI.HSSF.Util.HSSFColor.Black.Index;
            cellStyle.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cellStyle.LeftBorderColor = NPOI.HSSF.Util.HSSFColor.Black.Index;
            cellStyle.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cellStyle.RightBorderColor = NPOI.HSSF.Util.HSSFColor.Black.Index;
            cellStyle.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cellStyle.TopBorderColor = NPOI.HSSF.Util.HSSFColor.Black.Index;
            #region 表数据

            // 表数据    
            for (int k = 0; k < 2; k++)
            {
                DataRow dr = dt.Rows[k];
                NPOI.SS.UserModel.IRow row = hssfSheet.CreateRow(k + 2);
                row.Height = 30 * 20;

                for (int i = 0; i < 2; i += 2)
                {
                    row.CreateCell(i).SetCellValue(dr[0].ToString());
                    row.GetCell(i).CellStyle = cellStyle1;
                }

                for (int i = 2; i < 5; i += 3)
                {
                    row.CreateCell(i).SetCellValue(dr[1].ToString());
                    row.GetCell(i).CellStyle = cellStyle1;
                }

                for (int i = 5; i < 7; i += 2)
                {
                    row.CreateCell(i).SetCellValue(dr[2].ToString());
                    row.GetCell(i).CellStyle = cellStyle1;
                }
                for (int i = 7; i < 9; i += 2)
                {
                    row.CreateCell(i).SetCellValue(dr[3].ToString());
                    row.GetCell(i).CellStyle = cellStyle1;
                }
                for (int i = 9; i < 11; i += 2)
                {
                    row.CreateCell(i).SetCellValue(dr[4].ToString());
                    row.GetCell(i).CellStyle = cellStyle1;
                }
                for (int i = 11; i < 14; i += 3)
                {
                    row.CreateCell(i).SetCellValue(dr[5].ToString());
                    row.GetCell(i).CellStyle = cellStyle1;
                }

                row.CreateCell(1).SetCellValue("");
                row.GetCell(1).CellStyle = cellStyle1;
                row.CreateCell(3).SetCellValue("");
                row.GetCell(3).CellStyle = cellStyle1;
                row.CreateCell(4).SetCellValue("");
                row.GetCell(4).CellStyle = cellStyle1;
                row.CreateCell(6).SetCellValue("");
                row.GetCell(6).CellStyle = cellStyle1;
                row.CreateCell(8).SetCellValue("");
                row.GetCell(8).CellStyle = cellStyle1;
                row.CreateCell(10).SetCellValue("");
                row.GetCell(10).CellStyle = cellStyle1;
                row.CreateCell(12).SetCellValue("");
                row.GetCell(12).CellStyle = cellStyle1;
                row.CreateCell(13).SetCellValue("");
                row.GetCell(13).CellStyle = cellStyle1;
                hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 0, 1));
                hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 2, 4));
                hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 5, 6));
                hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 7, 8));
                hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 9, 10));
                hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 11, 13));
            }
            // 表数据    
            for (int k = 2; k < dt.Rows.Count; k++)
            {
                if (k == dt.Rows.Count - 1)
                {
                    DataRow drlast = dt.Rows[k];
                    NPOI.SS.UserModel.IRow rowlast = hssfSheet.CreateRow(k + 2);
                    rowlast.Height = 30 * 20;

                    for (int i = 0; i < 2 ; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue(drlast[0].ToString());
                        rowlast.GetCell(i).CellStyle = cellStyle1;
                    }

                    for (int i = 2; i < 4; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue("");
                        rowlast.GetCell(i).CellStyle = cellStyle1;
                    }

                    for (int i = 4; i < 6; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue(drlast[2].ToString());
                        rowlast.GetCell(i).CellStyle = cellStyle1;
                    }

                    for (int i = 6; i < 8; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue("");
                        rowlast.GetCell(i).CellStyle = cellStyle1;
                    }

                    for (int i = 8; i < 10; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue(drlast[4].ToString());
                        rowlast.GetCell(i).CellStyle = cellStyle1;
                    }
                    for (int i = 10; i < 14; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue("");
                        rowlast.GetCell(i).CellStyle = cellStyle1;
                    }
                    //hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 1, 7));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 0, 1));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 2, 3));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 4, 5));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 6, 7));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 8, 9));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 10, 13));
                }
                else
                {
                    DataRow dr = dt.Rows[k];
                    NPOI.SS.UserModel.IRow row = hssfSheet.CreateRow(k + 2);
                    row.Height = 30 * 20;

                    for (int i = 0; i < 1; i ++)
                    {
                        row.CreateCell(i).SetCellValue(dr[i].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }

                    for (int i = 1; i < 3; i++)
                    {
                        row.CreateCell(i).SetCellValue(dr[1].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }
                    for (int i = 3; i < 6; i++)
                    {
                        row.CreateCell(i).SetCellValue(dr[2].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }
                    for (int i = 6; i < 8; i++)
                    {
                        row.CreateCell(i).SetCellValue(dr[3].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }
                    for (int i = 8; i < 10; i++)
                    {
                        row.CreateCell(i).SetCellValue(dr[4].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }
                    for (int i = 10; i < 12; i++)
                    {
                        row.CreateCell(i).SetCellValue(dr[5].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }
                    for (int i = 12; i < 14; i++)
                    {
                        row.CreateCell(i).SetCellValue(dr[6].ToString());
                        row.GetCell(i).CellStyle = cellStyle;
                    }
                   
                    row.CreateCell(2).SetCellValue("");
                    row.GetCell(2).CellStyle = cellStyle;
                    row.CreateCell(4).SetCellValue("");
                    row.GetCell(4).CellStyle = cellStyle;
                    row.CreateCell(5).SetCellValue("");
                    row.GetCell(5).CellStyle = cellStyle;
                    row.CreateCell(7).SetCellValue("");
                    row.GetCell(7).CellStyle = cellStyle;
                    row.CreateCell(9).SetCellValue("");
                    row.GetCell(9).CellStyle = cellStyle;
                    row.CreateCell(11).SetCellValue("");
                    row.GetCell(11).CellStyle = cellStyle;
                    row.CreateCell(13).SetCellValue("");
                    row.GetCell(13).CellStyle = cellStyle;
                    
                    #region 合并单元格
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 1, 2));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 3, 5));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 6, 7));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 8, 9));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 10, 11));
                    hssfSheet.AddMergedRegion(new CellRangeAddress(k + 2, k + 2, 12, 13));
                    #endregion
                }

            }

            #endregion
            hssfSheet.PrintSetup.NoColor = true;
            hssfSheet.PrintSetup.Landscape = true;
            hssfSheet.PrintSetup.PaperSize = (short)PaperSize.A4;
            //是否自适应界面
            hssfSheet.FitToPage = true;
            string uploadPath = HttpContext.Current.Request.PhysicalApplicationPath + "Mfg/Temp/";
            if (!Directory.Exists(uploadPath))
            {
                Directory.CreateDirectory(uploadPath);
            }
            FileStream file = new FileStream(uploadPath + fileName + ".xls", FileMode.Create);
            hssfworkbook.Write(file);
            file.Close();
            var basePath = VirtualPathUtility.AppendTrailingSlash(HttpContext.Current.Request.ApplicationPath);
            //return (basePath + "Temp/" + fileName + ".xls");
            string fileURL = HttpContext.Current.Server.MapPath((basePath + "Mfg/Temp/" + fileName + ".xls"));//文件路径，可用相对路径
            try
            {
                FileInfo fileInfo = new FileInfo(fileURL);
                Response.Clear();
                Response.AddHeader("content-disposition", "attachment;filename=" + HttpContext.Current.Server.UrlEncode(fileInfo.Name.ToString()));//文件名
                Response.AddHeader("content-length", fileInfo.Length.ToString());//文件大小
                Response.ContentType = "application/octet-stream";
                Response.ContentEncoding = System.Text.Encoding.Default;
                Response.WriteFile(fileURL);
               
            }
            catch (Exception ex)
            {
                Response.Write(ex.Message);
            }
           

        }

        /// <summary>  
        /// 去除HTML标记  
        /// </summary>  
        /// <param name="htmlstring"></param>  
        /// <returns>已经去除后的文字</returns>  
        public static string RemoveHtml(string htmlstring)
        {
            //删除脚本      
            htmlstring =
                Regex.Replace(htmlstring, @"<script[^>]*?>.*?</script>",
                              "", RegexOptions.IgnoreCase);
            //删除HTML      
            htmlstring = Regex.Replace(htmlstring, @"<(.[^>]*)>", "", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"([\r\n])[\s]+", "", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"-->", "", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"<!--.*", "", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(quot|#34);", "\"", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(amp|#38);", "&", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(lt|#60);", "<", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(gt|#62);", ">", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(nbsp|#160);", "   ", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(iexcl|#161);", "\xa1", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(cent|#162);", "\xa2", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(pound|#163);", "\xa3", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&(copy|#169);", "\xa9", RegexOptions.IgnoreCase);
            htmlstring = Regex.Replace(htmlstring, @"&#(\d+);", "", RegexOptions.IgnoreCase);
            htmlstring = htmlstring.Replace("<", "");
            htmlstring = htmlstring.Replace(">", "");
            htmlstring = htmlstring.Replace("\r\n", "");
            return htmlstring;
        }

        //两个结构不同的DT合并
        /// <summary>
        /// 将两个列不同的DataTable合并成一个新的DataTable
        /// </summary>
        /// <param name="dt1">表1</param>
        /// <param name="dt2">表2</param>
        /// <param name="DTName">合并后新的表名</param>
        /// <returns></returns>
        public static DataTable UniteDataTable(DataTable dt1, DataTable dt2, DataTable dtRemark)
        {
            DataTable dt3 = dt1.Clone();

            object[] obj = new object[dt3.Columns.Count];

            for (int i = 0; i < dt1.Rows.Count; i++)
            {
                dt1.Rows[i].ItemArray.CopyTo(obj, 0);
                dt3.Rows.Add(obj);
            }
            DataRow dr = dt3.NewRow();
            object[] obj1 = new object[dt3.Columns.Count];
            for (int i = 0; i < dt2.Columns.Count; i++)
            {
                obj1[i] = dt2.Columns[i].ColumnName;
            }
            dr.ItemArray = obj1;
            dt3.Rows.Add(dr);
            object[] obj2 = new object[dt2.Columns.Count];
            //// 添加DataTable2的数据
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                dt2.Rows[i].ItemArray.CopyTo(obj2, 0);
                dt3.Rows.Add(obj2);
            }

            //// 添加DataTable2的数据
            for (int i = 0; i < dtRemark.Rows.Count; i++)
            {
                dtRemark.Rows[i].ItemArray.CopyTo(obj1, 0);
                dt3.Rows.Add(obj1);
            }

            return dt3;
        }
    }
}