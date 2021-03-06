﻿
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyCompletionRate.aspx.cs" Inherits="LiNuoMes.Report.DailyCompletionRate" %>

<!DOCTYPE html>

<html>
<head>
<title>力诺瑞特平板集热器</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />

    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../Content/scripts/plugins/printTable/jquery.printTable.js"></script>
    <script src="ExportGridToExcel.js"></script>

    <script>

        $(function () {
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height()-106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height()-106);
                }, 200);
            });

            InitPage();
            fnDate();
            
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "DailyCompletionRateReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() *0.64,
                colModel: [
                      { label: '日期', name: '0', index: '0', width: panelwidth * 0.055, align: 'left', sortable: false },
                      {
                          label: '1', name: '1', index: '1', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '2', name: '2', index: '2', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '3', name: '3', index: '3', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '4', name: '4', index: '4', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '5', name: '5', index: '5', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '6', name: '6', index: '6', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '7', name: '7', index: '7', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '8', name: '8', index: '8', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '9', name: '9', index: '9', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '10', name: '10', index: '10', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '11', name: '11', index: '11', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '12', name: '12', index: '12', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '13', name: '13', index: '13', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '14', name: '14', index: '14', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '15', name: '15', index: '15', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '16', name: '16', index: '16', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '17', name: '17', index: '17', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '18', name: '18', index: '18', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '19', name: '19', index: '19', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '20', name: '20', index: '20', width: panelwidth * 0.028, align: 'left'
                      },
                      {
                          label: '21', name: '21', index: '21', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '22', name: '22', index: '22', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '23', name: '23', index: '23', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '24', name: '24', index: '24', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '25', name: '25', index: '25', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '26', name: '26', index: '26', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '27', name: '27', index: '27', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '28', name: '28', index: '28', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '29', name: '29', index: '29', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '30', name: '30', index: '30', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '31', name: '31', index: '31', width: panelwidth * 0.029, align: 'left'
                      },
                      {
                          label: '汇总', name: '32', index: '32', width: panelwidth * 0.04, align: 'left'
                      },

                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    //$("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });

            //查询事件
            $("#spn_Search").click(function () {  

                  $gridTable.jqGrid('setGridParam', {
                      datatype: 'json',
                      postData: {
                          YEAR: $("#YEAR").val(),
                          
                      }
                  }).trigger('reloadGrid');
                  
                  $.ajax({
                      url: "GetReportInfo.ashx",
                      data: {
                          Action: "GetUserAttendenceChart",
                          DATE: $("#YEAR").val()
                      },
                      type: "post",
                      datatype: "json",
                      success: function (data) {
                          var datalength = JSON.parse(data).catagory.length;
                          
                          for (var i = datalength; i < 31; i++) {
                              $gridTable.hideCol("" + (i + 1) + "").trigger("reloadGrid");
                          }

                         
                          for (var i = 28; i < datalength; i++) {
                              $gridTable.showCol("" + (i + 1) + "").trigger("reloadGrid");
                          }
                          
                      },
                      error: function (msg) {
                          dialogMsg("数据访问异常", -1);
                      }
                  });
            });

            
        }

        function fnDate() {
            var xhr = null;
            if (window.XMLHttpRequest) {
                xhr = new window.XMLHttpRequest();
            } else { // ie
                xhr = new ActiveObject("Microsoft")
            }
            // 通过get的方式请求当前文件
            xhr.open("get", "/");
            xhr.send(null);
            // 监听请求状态变化
            xhr.onreadystatechange = function () {
                var time = null,
                    curDate = null;
                if (xhr.readyState === 2) {
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    var month = curDate.getMonth() + 1;
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                   
                    $('#YEAR').val(curDate.getFullYear() + '-' + month);
                   
                    var year = $("#YEAR").val();
                    
                    $("#title").html(year  + '每日生产完成率报表');
                }
            }

        }

        function settitle()
        {
            var year = $("#YEAR").val();
            //var month = $("#MONTH").val();
            $("#title").html(year  + '每日生产完成率报表');

        }

        //打印
        function btn_print(event) {
            try {
                $("#gridPanel").printTable(gridPanel);
            } catch (e) {
                dialogMsg("Exception thrown: " + e, -1);
            }
        }

        //导出
        function btn_export(event) {

            var title = $("#title").html();
            ExportJQGridDataToExcel('#gridTable', title);
        }

    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav"></div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap"></div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">每日生产完成率报表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >查询日期：</th>
                                    <td class="formValue" colspan="2" >
                                        <input  id="YEAR" type="text"  class="Wdate timeselect"  onfocus="WdatePicker({dateFmt:'yyyy-MM',onpicked:settitle})" readonly/>
                                       
                                    </td>
                                    <td class="formValue">                                     
                                        <a id="spn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>  
                                    </td>
                                </tr> 
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
         <div class="titlePanel">
        <div class="toolbar">
            <div class="btn-group">
                <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                <a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>
            </div>
         </div>
         </div>
         <div class="ui-report" style="margin-top:0.5%; overflow: hidden; ">
              <div class="gridPanel" id="gridPanel">
                  <div class="printArea">
                      <div class="grid-title"> 
                          <h2 style="text-align:center;" id="title"></h2> 
                     </div> 
                      <table id="gridTable"></table>                      
                  </div>
              </div>
         </div>
    </div>
</body>
</html>


