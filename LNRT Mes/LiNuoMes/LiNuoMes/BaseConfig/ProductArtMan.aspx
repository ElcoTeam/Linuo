<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductArtMan.aspx.cs" Inherits="LiNuoMes.BaseConfig.ProductArtMan" %>

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
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
  
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
                    $('#areascontent').height($(window).height() - 106);
                }, 200);
            });
           
            GetGrid();
            CreateSelect();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "./GetSetBaseConfig.ashx",
                datatype: "json",
                postData: {
                    "Action": "Process_Art_LIST",
                    ProcessCode: $("#ProcessName").val()
                },
                height: $('#areascontent').height() - 200,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 100, align: 'center', sortable: false },
                    { label: '工序编号', name: 'ProcessCode', index: 'ProcessCode', width: 200, align: 'center', sortable: false },
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 300, align: 'left', sortable: false },
                    { label: '工艺名称', name: 'ArtName', index: 'ArtName', width: 300, align: 'center', sortable: false },
                    { label: '值', name: 'ArtValue', index: 'ArtValue', width: 200, align: 'center', sortable: false },
                    { label: '更新人员', name: 'UpdateUser', index: 'UpdateUser', width: 200, align: 'center', sortable: false },
                    {
                        label: '操作', width: 200, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                       
                         return '<button onclick=\"showdlg(\'CHECK\', \'' + rowObject.ID + '\')\" class=\"btn btn-success\"  style=\"cursor: pointer;\"><i class="fa fa-check-square-o"></i>查看</button>'
                                 + '<button onclick=\"showdlg(\'EDIT\',  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-edit"></i>修改</button>'
                   + '<button  onclick=\"btn_delete(\'' + rowObject.ID + '\')\" class=\"btn btn-danger\"  style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-trash"></i>删除</button>';
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'InturnNumber asc',
                rownumbers: false,
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });

            //查询事件
            $("#spn_Search").click(function () {
                var ProcessCode = $("#ProcessName").val();
                
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        ProcessCode: ProcessCode
                    }, page: 1
                }).trigger('reloadGrid');

            });
           
        }

        //构造select
        function CreateSelect() {
            $("#ProcessName").empty();
            var optionstring = "";
            $.ajax({
                url: "../Equipment/EquDeviceInfo.aspx/GetProcessInfo",
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


        //新增工艺信息
        function btn_Add(event)
        {
            showdlg('ADD', 0);
        }
        //编辑信息
        function showdlg(OPtype, ArtId) {
            if (ArtId == undefined) {
                ArtId = $("#gridTable").getRowData(selectedRowIndex)["ID"];
            }

            if (OPtype == undefined) {
                OPtype = "CHECK";
            }

            var sTitle = "";
            if (OPtype == "CHECK") {
                sTitle = "查看生产工艺信息";
            }
            else if (OPtype == "EDIT") {
                sTitle = "修改生产工艺信息";
            }
            else if (OPtype == "ADD") {
                sTitle = "新增生产工艺信息";
            }

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: "ProductArtEdit.aspx?OPtype=" + OPtype + "&ArtId=" + ArtId,
                width: "400px",
                height: "280px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除信息
        function btn_delete(ArtId) {
            if (ArtId == undefined) {
                ArtId = $("#gridTable").getRowData(selectedRowIndex)["ID"];
            }
           
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "GetSetBaseConfig.ashx",
                            data: {
                                Action: "Process_Art_DEL",
                                ArtId: ArtId
                            },
                            type: "post",
                            datatype: "json",
                            success: function (data) {
                                data = JSON.parse(data);
                                if (data.result == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable").trigger("reloadGrid");
                                }
                                else if (data.result == "failed") {
                                    dialogMsg(data.msg, -1);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                Loading(false);
                                dialogMsg(errorThrown, -1);
                            },
                            beforeSend: function () {
                                Loading(true, "正在删除数据");
                            },
                            complete: function () {
                                Loading(false);
                            }
                        });
                    }, 500);
                }
            });
        }

       
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body">

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav">
       
    </div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap">
      
    </div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">生产工艺信息</strong></div>
                        <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                               <div class="lr-layout-tool-item">
                                    <span class="formTitle">工序名称：</span>
                                    <select class="form-control" id="ProcessName"></select>   
                               </div>
                               <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                    <div id="multiple_condition_query" class="lr-query-wrap">
                                    <div class="lr-query-btn" id="spn_Search" style="font-size:10px;width:80px;">
                                        <i  class="fa fa-search"></i>&nbsp;查询</>  
                                    </div>
                                   
                                </div>
                                </div>
                                </div>
                             <div class=" lr-layout-tool-right">
                                 <div class="btn-group">
                                     <a id="lr-Add" class="btn btn-default" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建生产工艺</a>
                                 </div>
                             </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="rows" style="margin-top:3.5%; overflow: hidden; ">
             <div class="gridPanel">
                  <table id="gridTable"></table>
                  <div id="gridPager"></div>
             </div>
         </div>
    </div>

</body>
</html>







