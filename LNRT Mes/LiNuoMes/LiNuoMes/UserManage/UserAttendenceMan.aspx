<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserAttendenceMan.aspx.cs" Inherits="LiNuoMes.UserManage.UserAttendenceMan" %>

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
    <link href="../css/learun-ui.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
     <script src="../My97DatePicker/WdatePicker.js"></script>

     <script>

         var lastSelected = "";

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
            $gridTable.jqGrid({
                url: "hs/GetAttendenceInfo.ashx",
                datatype: "local",
                height: $('#areascontent').height() -200,
                colModel: [
                    
                    { label: '日期', name: 'Date', index: 'Date', width: 100, align: 'center',sortable: false },
                    {
                        label: '出勤人数', name: 'AttendanceNum', index: 'AttendanceNum', width: 200, align: 'center', sortable: false
                    },
                    {
                        label: '当日工作时间', name: 'WorkHours', index: 'WorkHours', width: 200, align: 'center', sortable: false
                    },
                    {
                        label: '出勤时间', name: 'TotalAttendenceHours', index: 'TotalAttendenceHours', width: 200, align: 'center', sortable: false
                    },
                    {
                        label: '有效生产时间', name: 'ActiveWorkHours', index: 'ActiveWorkHours', width: 200, align: 'center', sortable: false
                    },
                    {
                        label: '操 作', name: '', index: '', width: 240, align: 'left', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span id=\"btn_edit' + rowObject.ID + '\" onclick=\"btn_edit(  \'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-edit" ></i>修改</span>';
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 12,
                rowList: [12, 20, 40],
                pager: "#gridPager",
                sortname: 'Date',
                rownumbers: true,
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
                var date= $("#DATE").val();
                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        DATE: date
                    }
                }).trigger('reloadGrid');
            });

            //查询回车
            //$('#ItemName').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#spn_Search').trigger("click");
            //    }
            //});
            //$('#DATE').bind('onpicking', function (event) {
            //    alert(111);
            //    $('#spn_Search').trigger("click");
            //});
        }

        //编辑信息
        function btn_edit(date) {
            if (date == undefined) {
                date = $("#gridTable").jqGridRowValue("Date");
            }
            if (date >= 1 && date <= 9) {
                date = "0" + date;
            }
            var datetime = $("#DATE").val() + '-' + date;
           
            dialogOpen({
                id: "Form", 
                title: '修改出勤信息:' + datetime,
                url: '../UserManage/UserAttendenceEdit.aspx?date=' + datetime + '',
                width: "400px",
                height: "300px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick();
                }
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
                    var seperator1 = "-";
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month
                    $('#DATE').val(currentdate);
                }
            }

        }

        function setsearch() {
            $('#spn_Search').trigger("click");
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">每日出勤管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >查询月份：</th>
                                    <td class="formValue" >
                                        <input id="DATE" type="text" class="Wdate  form-control"  onfocus="WdatePicker({dateFmt:'yyyy-MM',onpicked:setsearch})"/> 
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

         <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
              </div>
         </div>
    </div>

</body>
</html>

