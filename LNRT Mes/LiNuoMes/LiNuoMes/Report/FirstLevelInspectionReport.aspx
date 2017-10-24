
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FirstLevelInspectionReport.aspx.cs" Inherits="LiNuoMes.Report.FirstLevelInspectionReport" %>

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

   <%-- <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />--%>
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
   <%-- <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />--%>
    <link href="../Content/styles/learun-report.css" rel="stylesheet" />
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
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#gridTable1').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height() - 106);
                }, 200);
            });
            InitPage();
            fnDate();
            CreateProcessList();

            $("#ProcessName").change(function () {
                CreateDeviceList();
            })
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var $gridTable1 = $('#gridTable1');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "FirstLevelInspectionReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.35,
                colModel: [
                      { label: '序号', name: '0', index: '0', width: 50, align: 'left', sortable: false },
                      { label: '点检内容', name: '0', index: '0', width: 250, align: 'left', sortable: false },
                      {
                          label: '1', name: '1', index: '1', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "<i>&nbsp;</i>";
                          }
                      },
                      {
                          label: '2', name: '2', index: '2', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "<i>&nbsp;</i>";
                          }
                      },
                      {
                          label: '3', name: '3', index: '3', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "<i>&nbsp;</i>";
                          }
                      },
                      {
                          label: '4', name: '4', index: '4', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "<i>&nbsp;</i>";
                          }
                      },
                      {
                          label: '5', name: '5', index: '5', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : " ";
                          }
                      },
                      {
                          label: '6', name: '6', index: '6', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '7', name: '7', index: '7', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '8', name: '8', index: '8', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '9', name: '9', index: '9', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '10', name: '10', index: '10', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '11', name: '11', index: '11', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '12', name: '12', index: '12', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '13', name: '13', index: '13', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '14', name: '14', index: '14', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '15', name: '15', index: '15', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '16', name: '16', index: '16', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '17', name: '17', index: '17', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '18', name: '18', index: '18', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '19', name: '19', index: '19', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '20', name: '20', index: '20', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '21', name: '21', index: '21', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '22', name: '22', index: '22', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '23', name: '23', index: '23', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '24', name: '24', index: '24', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '25', name: '25', index: '25', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '26', name: '26', index: '26', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '27', name: '27', index: '27', width: panelwidth * 0.029, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '28', name: '28', index: '28', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '29', name: '29', index: '29', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '30', name: '30', index: '30', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
                      },
                      {
                          label: '31', name: '31', index: '31', width: 50, align: 'left',
                          formatter: function (cellvalue, options, rowObject) {
                              return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "";
                          }
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


            $gridTable1.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "FirstLevelInspectionProblemReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.23,
                colModel: [
                    {
                        label: '序号', name: 'ProblemID', index: 'ProblemID', width: panelwidth * 0.025, align: 'left', sortable: false
                    },
                    {
                        label: '点检日期', name: 'InspectionDate', index: 'InspectionDate', width: panelwidth * 0.08, align: 'left', sortable: false
                    },
                    {
                        label: '问题记录', name: 'InspectionProblem', index: 'InspectionProblem', width: panelwidth * 0.52, align: 'left', sortable: false
                    },
                    {
                        label: '发现问题', name: 'FindProblem', index: 'FindProblem', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '解决问题', name: 'RepairProblem', index: 'RepairProblem', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '遗留问题', name: 'ReaminProblem', index: 'ReaminProblem', width: panelwidth * 0.1, align: 'center'
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

                $("#subtitle").html($("#YEAR").val() + "月设备日常维护保养点检卡");
                $("#DeviceCodeLabel").html($("#DeviceName").val());
                $("#DeviceNameLabel").html($("#DeviceName").find("option:selected").text());
                $("#ProcessNameLabel").html($("#ProcessName").find("option:selected").text());

                //点检表记录
                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        YEAR: $("#YEAR").val(),
                        ProcessCode: $("#ProcessName").val(),
                        DeviceName: $("#DeviceName").find("option:selected").text()
                    }
                }).trigger('reloadGrid');

                //点检表问题记录
                $gridTable1.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        YEAR: $("#YEAR").val(),
                        DeviceName: $("#DeviceName").val()
                    }
                }).trigger('reloadGrid');
            });
        }

        //加载工序列表
        function CreateProcessList() {
            $("#ProcessName").empty();
            var optionstring = "";
            $.ajax({
                url: "FirstLevelInspectionReport.aspx/GetProcessInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";

                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);


                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

        }

        function CreateDeviceList() {
            //加载设备列表
            $("#DeviceName").empty();
            var optionstring1 = "";
            $.ajax({
                url: "FirstLevelInspectionReport.aspx/GetDeviceInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:'" + $("#ProcessName").val() + "'}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data.d != '') {
                        var data1 = eval('(' + data.d + ')');
                        var i = 0;
                        for (i in data1) {
                            optionstring1 += "<option value=\"" + data1[i].DeviceCode + "\" >" + data1[i].DeviceName.trim() + "</option>";
                        }
                        $("#DeviceName").html(optionstring1);
                    }
                    else {
                        $("#DeviceName").html("");
                    }

                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

        }

        //当前日期
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
                    $("#subtitle").html($("#YEAR").val() + "月设备日常维护保养点检卡");
                }
            }

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
        //function btn_export(event) {
        //    var title = $("#title").html();
        //    ExportJQGridDataToExcel('#gridTable', title);
        //}

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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">一级点检表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >工序名称：</th>
                                    <td class="formValue" >
                                        <select class="form-control" id="ProcessName"></select>
                                    </td>
                                    <th class="formTitle" >设备名称：</th>
                                    <td class="formValue" >
                                        <select class="form-control" id="DeviceName"></select>
                                    </td>
                                    <th class="formTitle" >查询日期：</th>
                                    <td class="formValue" >
                                        <input  id="YEAR" type="text"  class="Wdate timeselect"  onfocus="WdatePicker({dateFmt:'yyyy-MM'})" readonly/>
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
        <div class="ui-report"> 
        <div class="titlePanel">
        <div class="toolbar">
            <div class="btn-group">
                <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                <%--<a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>--%>
            </div>
         </div>
         </div>
         <div class="gridPanel" id="gridPanel">
             <div class="printArea">
                  <div class="grid-title">
                        <h5 style="text-align:left;">山东力诺瑞特新能源有限公司</h5> 
                        <h4 style="text-align:center;" id="subtitle"></h4> 
                   </div>  
                   <div class="grid-subtitle">
                       设备编号: <label id="DeviceCodeLabel"  style="width: 100px;"  ></label> 
                       设备名称: <label id="DeviceNameLabel"  style="width: 200px;"  ></label>
                       规格型号: <label id="DeviceKindLabel"  style="width: 50px;"  ></label>
                       工序名称: <label id="ProcessNameLabel"  style="width: 200px;"  ></label>
                       操作者:   <label id="OpeartePerson"  style="width: 100px;"  ></label>
                   </div>
                 <table id="gridTable" style="width:100%;"></table>       
             </div>
             <div class="printArea">           
                 <table id="gridTable1"></table>   
             </div>
         </div>
         </div>
    </div>
     <style>
         .timeselect {
            width: 150px;
            height: 35px;
            font-size: 20px;
         }
    </style>
</body>
</html>







