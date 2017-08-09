using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;

namespace LiNuoMes.Report
{
    /// <summary>
    /// ExportGridToExcel 的摘要说明
    /// </summary>
    public class ExportGridToExcel : IHttpHandler
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

            if (File.Exists(excelFilename))
                File.Delete(excelFilename);

            ExportDataSetToExcel(dt, excelFilename, context.Response);

        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
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
                for (int i = 0; i < Lines.GetLength(0); i++)
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

        /// <summary>  
        /// 将DataTable导出到Excel  
        /// </summary>  
        /// <param name="dt">DataTable</param>   
        /// <param name="fileName">仅文件名（非路径）</param>   
        /// <returns>返回Excel文件绝对路径</returns>  
        public void ExportDataSetToExcel(DataTable dt, string fileName, System.Web.HttpResponse Response)
        {
            int dtcolunmnum = dt.Columns.Count;
            #region 表头
            HSSFWorkbook hssfworkbook = new HSSFWorkbook();

            NPOI.SS.UserModel.ISheet hssfSheet = hssfworkbook.CreateSheet(fileName);
            hssfSheet.DefaultColumnWidth = 13;
            //hssfSheet.SetColumnWidth(0, 20 * 256);
            //hssfSheet.SetColumnWidth(3, 20 * 256);

            // 表头  
            NPOI.SS.UserModel.IRow tagRow0 = hssfSheet.CreateRow(0);
            tagRow0.Height = 40 * 40;
            ICell cell0 = tagRow0.CreateCell(0);
            //设置单元格内容
            cell0.SetCellValue("力诺瑞特制造工厂");
            hssfSheet.AddMergedRegion(new CellRangeAddress(0, 0, 0, dtcolunmnum-1));

            NPOI.SS.UserModel.IRow tagRow1 = hssfSheet.CreateRow(1);
            tagRow1.Height = 30 * 20;
            ICell cell1 = tagRow1.CreateCell(0);
            //设置单元格内容
            cell1.SetCellValue(fileName);
            hssfSheet.AddMergedRegion(new CellRangeAddress(1, 1, 0, dtcolunmnum-1));

            // 标题样式  
            NPOI.SS.UserModel.ICellStyle tagStyle = hssfworkbook.CreateCellStyle();
            tagStyle.Alignment = NPOI.SS.UserModel.HorizontalAlignment.CENTER;
            tagStyle.VerticalAlignment = VerticalAlignment.CENTER;
            IFont font = hssfworkbook.CreateFont();
            font.FontHeightInPoints = 16;
            font.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.BOLD;
            font.FontName = "宋体";
            tagStyle.SetFont(font);//HEAD 样式
            cell0.CellStyle = tagStyle;
            NPOI.SS.UserModel.ICellStyle tagStyle1 = hssfworkbook.CreateCellStyle();
            tagStyle1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.CENTER;
            tagStyle1.VerticalAlignment = VerticalAlignment.CENTER;
            cell1.CellStyle = tagStyle1;

            NPOI.SS.UserModel.ICellStyle cellStyle = hssfworkbook.CreateCellStyle();
            cellStyle.Alignment = NPOI.SS.UserModel.HorizontalAlignment.CENTER;
            cellStyle.VerticalAlignment = VerticalAlignment.CENTER;
            cellStyle.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            cellStyle.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            cellStyle.BottomBorderColor = NPOI.HSSF.Util.HSSFColor.BLACK.index;
            cellStyle.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
            cellStyle.LeftBorderColor = NPOI.HSSF.Util.HSSFColor.BLACK.index;
            cellStyle.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
            cellStyle.RightBorderColor = NPOI.HSSF.Util.HSSFColor.BLACK.index;
            cellStyle.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
            cellStyle.TopBorderColor = NPOI.HSSF.Util.HSSFColor.BLACK.index;
            
            #endregion

            // 表数据    
            for (int k = 0; k < dt.Rows.Count; k++)
            {
              
                    DataRow drlast = dt.Rows[k];
                    NPOI.SS.UserModel.IRow rowlast = hssfSheet.CreateRow(k + 2);
                    rowlast.Height = 30 * 20;
                
                    for (int i = 0; i < dt.Columns.Count; i++)
                    {
                        rowlast.CreateCell(i).SetCellValue(drlast[i].ToString());
                        rowlast.GetCell(i).CellStyle = cellStyle;
                       
                    }   
            }

            // 表数据    
            //for (int k = 0; k < dt.Rows.Count; k++)
            //{
            //    hssfSheet.AutoSizeColumn(k);
            //}

            //获取当前列的宽度，然后对比本列的长度，取最大值
            for (int columnNum = 0; columnNum <= dt.Columns.Count; columnNum++)
            {
                int columnWidth = hssfSheet.GetColumnWidth(columnNum) / 256;
                for (int rowNum = 1; rowNum <= hssfSheet.LastRowNum; rowNum++)
                {
                    IRow currentRow;
                    //当前行未被使用过
                    if (hssfSheet.GetRow(rowNum) == null)
                    {
                        currentRow = hssfSheet.CreateRow(rowNum);
                    }
                    else
                    {
                        currentRow = hssfSheet.GetRow(rowNum);
                    }

                    if (currentRow.GetCell(columnNum) != null)
                    {
                        ICell currentCell = currentRow.GetCell(columnNum);
                        int length = Encoding.Default.GetBytes(currentCell.ToString()).Length;
                        if (columnWidth < length)
                        {
                            columnWidth = length;
                        }
                    }
                }
                hssfSheet.SetColumnWidth(columnNum, columnWidth * 256);
            }

            hssfSheet.PrintSetup.NoColor = true;
            hssfSheet.PrintSetup.Landscape = true;
            hssfSheet.PrintSetup.PaperSize = (short)PaperSize.A4;

            //是否自适应界面
            hssfSheet.FitToPage = true;

            //保存excel文件
            string uploadPath = HttpContext.Current.Request.PhysicalApplicationPath + "Report/Temp/";
            if (!Directory.Exists(uploadPath))
            {
                Directory.CreateDirectory(uploadPath);
            }
            FileStream file = new FileStream(uploadPath + fileName + ".xls", FileMode.Create);
            hssfworkbook.Write(file);
            file.Close();
            var basePath = VirtualPathUtility.AppendTrailingSlash(HttpContext.Current.Request.ApplicationPath);
            //return (basePath + "Temp/" + fileName + ".xls");
            string fileURL = HttpContext.Current.Server.MapPath((basePath + "Report/Temp/" + fileName + ".xls"));//文件路径，可用相对路径
            FileInfo fileInfo = new FileInfo(fileURL);
            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=" + HttpContext.Current.Server.UrlEncode(fileInfo.Name.ToString()));//文件名
            Response.AddHeader("content-length", fileInfo.Length.ToString());//文件大小
            Response.ContentType = "application/octet-stream";
            Response.ContentEncoding = System.Text.Encoding.Default;
            Response.WriteFile(fileURL);
            
        }
    }
}