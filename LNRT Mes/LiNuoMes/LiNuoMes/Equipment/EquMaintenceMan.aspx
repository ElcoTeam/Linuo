<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintenceMan.aspx.cs" Inherits="LiNuoMes.Equipment.EquMaintenceMan" %>

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
        var currentdate = "";
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

            $("#spn_Search").click(function () {
                if (!$("#content").hasClass("active")) {
                    $("#content").addClass("active")

                } else {
                    $("#content").removeClass("active")

                }
            });
            //GetGrid();
            fnDate();
            CreateSelect();
            SelectCurrentMaintence();
            //一级保养 执行维护
            $("#btn_FirstLevel").click(function () {
               
                $.ajax({
                    url: "EquFirstLevelMaintence.aspx/GetFirstLevelList",
                    type: "post",
                    dataType: "json",
                    data: "{}",
                    contentType: "application/json;charset=utf-8",
                    success: function (data) {
                        if (data.d.length == 0) {
                            dialogAlert("当前无一级保养计划", 0);
                        }
                        else {
                            dialogOpen({
                                id: "Form",
                                title: '一级保养信息维护',
                                url: '../Equipment/EquFirstLevelMaintence.aspx',
                                //url: '../Equipment/EquSecondLevelMaintence.aspx',
                                width: "900px",
                                height: "800px",
                                //btn: null,
                                callBack: function (iframeId) {
                                    top.frames[iframeId].AcceptClick($("#gridTable"));
                                }
                            });    
                        }
                        Loading(false);
                    }, beforeSend: function () {

                        Loading(true);
                    }
                });

            })

            //二级保养 执行维护
            $("#btn_SecondLevel").click(function () {
                $.ajax({
                    url: "EquSecondLevelMaintence.aspx/GetSecondLevelList",
                    data: "{}",
                    type: "post",
                    dataType: "json",
                    contentType: "application/json;charset=utf-8",
                    success: function (data) {
                        console.log(data.d);
                        if (data.d.length==0)
                        {
                            dialogAlert("当日无可维护二级保养",0);
                        }
                        else
                        {
                            dialogOpen({
                                id: "Form",
                                title: '二级保养信息维护--执行',
                                url: '../Equipment/EquSecondLevelMaintence.aspx',
                                width: "1300px",
                                height: "800px",
                                btn: null
                                //callBack: function (iframeId) {
                                //    top.frames[iframeId].AcceptClick1($("#gridTable"));
                                //}
                            });
                        }
                        Loading(false);
                    }, beforeSend: function () {

                        Loading(true);
                    }
                });
            })


            //编辑生产停止时间
            $("#btn_TotalTime").click(function () {
                dialogOpen({
                    id: "UploadifyForm",
                    title: '当日保养维护时间统计',
                    //contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                    url: './DailyMaintenceTime.aspx?currentdate=' + currentdate,
                    width: "400px",
                    height: "200px",
                    callBack: function (iframeId) {
                        top.frames[iframeId].AcceptClick();
                    }
                });

            })
          
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "hs/GetEquMaintenceMan.ashx",
                datatype: "json",
                postData: {
                    PmStartDate: $("#PmStartDate").val(),
                    PmFinishDate: $("#PmFinishDate").val()
                },
                height: $('#areascontent').height() -200,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '保养规范编号', name: 'PmSpecCode', hidden: true },
                    {
                        label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 150, align: 'left', sortable: false
                    },
                    { label: '保养类别', name: 'PmType', index: 'PmType', width: 100, align: 'left', sortable: false },
                    { label: '保养类型', name: 'PmLevel', index: 'PmLevel', width: 100, align: 'left', sortable: false },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'left', sortable: false },
                    { label: '保养规范名称', name: 'PmSpecName', index: 'PmSpecName', width: 200, align: 'left', sortable: false },
                    //{
                    //    label: '保养规范', name: 'PmSpecFile', index: 'PmSpecFile', width: 100, align: 'center', sortable: false,
                    //    formatter: function (cellvalue, options, rowObject) {
                    //        return '<span onclick=\"btn_look(\'' + rowObject[1] + '\',\'' + rowObject[7] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>';
                    //    }
                    //},
                   
                    { label: '保养计划名称', name: 'PmPlanName', index: 'PmPlanName', width: 250, align: 'left', sortable: false },
                    {
                        label: '计划内次数', name: 'PmPlanCount', index: 'PmPlanCount', width: 100, align: 'left', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            if (rowObject[3] == '计划内保养')
                            {
                                return '第' + cellvalue + '次';
                            }
                            else
                            {
                                return '';
                            }
                        }
                    },
                    { label: '执行情况', name: 'PmStatus', index: 'PmStatus', width: 100, align: 'left', sortable: false },
                    { label: '计划保养日期', name: 'PmPlanDate', index: 'PmPlanDate', width: 150, align: 'left', sortable: false },
                   
                    { label: '保养人', name: 'PmOper', index: 'PmOper', width: 100, align: 'left', sortable: false },
                    { label: '处理时间', name: 'UpdateTime', index: 'UpdateTime', width: 250, align: 'left', sortable: false },
                    {
                        label: '操作', name: '', index: '', width: 100, align: 'left', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            if (rowObject[3] == '计划外保养')
                            {
                                return '<span onclick=\"btn_look(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_edit(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>修改</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-trash-o"></i>删除</span>';
                            }
                            else if (rowObject[9] == '已完成' && rowObject[4] == '一级保养')
                            {
                                return '<span onclick=\"btn_lookfirstlevel(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看保养记录</span>';
                            }
                                //else if (rowObject[9]=='已完成') {
                                //    return '<span onclick=\"btn_searchman1(\'' + rowObject[0] + '\',\'' + rowObject[10] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>';
                                //        //+ '<span onclick=\"btn_editman1(\'' + rowObject[0] + '\',\'' + rowObject[10] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>修改</span>';
                                //}
                                //else if (rowObject[9] == '未完成') {
                                //    return '<span onclick=\"btn_searchman(\'' + rowObject[0] + '\',\'' + rowObject[10] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>';
                                //        //+ '<span onclick=\"btn_executeman(\'' + rowObject[0] + '\',\'' + rowObject[8] + '\',\'' + rowObject[10] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>执行</span>';
                                //}
                            else return '';

                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rownumWidth: 50,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'PmType asc',
                rownumbers: true,
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
            $("#lr_btn_querySearch").click(function () {
                var processName = $("#ProcessName").val();
                var deviceName = $("#DeviceName").val();
                var PmType = $("#PmType").val();
                var PmLevel = $("#PmLevel").val();
                var Status = $("#Status").val(); 
                var PmSpecName= $("#PmSpecName").val(); 
                var PmPlanName= $("#PmPlanName").val(); 
                var PmStartDate= $("#PmStartDate").val(); 
                var PmFinishDate = $("#PmFinishDate").val();
               
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        ProcessName: processName,
                        DeviceName: deviceName,
                        PmType: PmType,
                        PmLevel: PmLevel,
                        Status: Status,
                        PmSpecName: PmSpecName,
                        PmPlanName: PmPlanName,
                        PmStartDate: PmStartDate,
                        PmFinishDate: PmFinishDate
                    }, page: 1
                }).trigger('reloadGrid');

            });
            //查询回车
            //$('#orderno').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#btn_Search').trigger("click");
            //    }
            //});
        }

        //构造select
        function CreateSelect() {
            $("#ProcessName").empty();
            var optionstring = "";

            $.ajax({
                url: "EquDeviceInfo.aspx/GetProcessInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessName + "\" >" + data1[i].ProcessName.trim() + "</option>";
                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);  
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });           
        }
        

        //选取当日需要维护的二级保养
        function SelectCurrentMaintence()
        {
            var optionstring = "";
            $.ajax({
                url: "EquMaintenceMan.aspx/GetSecondMaintenceInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data.d != '') {
                        var data1 = eval('(' + data.d + ')');
                        var i = 0;
                        for (i in data1) {
                            //console.log(data.d[i].PmPlanCode);
                            optionstring += "" + data1[i].PmPlanCode + ",";
                        }
                        
                        dialogAlert("当前可维护二级保养:" + optionstring, 0);
                    }
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

        }


        //新建计划外保养
        function btn_Add(event) {
            dialogOpen({
                id: "Form",
                title: '计划外保养信息维护--新增',
                url: '../Equipment/EquMaintenceExtraManEdit.aspx?actionname=0',
                width: "750px",
                height: "500px",
                async: false,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //查看计划外保养  1:查看
        function btn_search(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '计划外保养信息维护--查看',
                url: '../Equipment/EquMaintenceExtraManEdit.aspx?actionname=1&equid=' + equid + '',
                width: "750px",
                height: "500px",
                btn: null
            });
        }

        //编辑计划外保养  2：编辑
        function btn_edit(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '计划外保养信息维护--修改',
                url: '../Equipment/EquMaintenceExtraManEdit.aspx?actionname=2&equid=' + equid + '',
                width: "750px",
                height: "500px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除计划外保养
        function btn_delete(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "EquMaintenceMan.aspx/DeleteMaintenceExtraMan",
                            data: "{EquID:'" + equid + "'}",
                            type: "post",
                            dataType: "json",
                            contentType: "application/json;charset=utf-8",
                            success: function (data) {
                                if (data.d == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable").trigger("reloadGrid");
                                }
                                else if (data.d == "falut") {
                                    dialogMsg("删除失败", -1);
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

       

        //查看一级保养信息
        function btn_lookfirstlevel(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '一级保养信息维护--查看',
                url: '../Equipment/EquFirstLevelManEdit.aspx?equid=' + equid + '',
                width: "750px",
                height: "500px",
                btn: null
            });
        }

        //查看操作规范文档
        function btn_look(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("PmSpecCode");
                filepath = $("#gridTable").jqGridRowValue("PmSpecFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            dialogOpen({
                id: "UploadifyForm",
                title: '查看文件-' + objID,
                //contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                url: './FileSearchInfo.aspx?folderId=' + objID,
                width: "1000px",
                height: "800px",
                btn: null
            });
        }

        //设置开始时间
        function setStartTime(){
            if ($("#PmFinishDate").val() == "")
            {
                dialogMsg("请选择结束日期",0);
            }
            else
            {
                $('#lr_btn_querySearch').trigger("click");
            }
        }

        //设置结束时间
        function setEndTime() {
            if ($("#PmStartDate").val() == "") {
                dialogMsg("请选择开始日期", 0);
            }
            else {
                $('#lr_btn_querySearch').trigger("click");
            }
        }


        //设置默认时间选择
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
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    $("#PmStartDate").val(currentdate);
                    $("#PmFinishDate").val(currentdate);
                    GetGrid();
                }
            }
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备保养管理</strong></div>
                         <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                               <div class="lr-layout-tool-item">
                                       <span class="formTitle">计划起止日期：</span>
                                       <input id="PmStartDate"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'PmFinishDate\')}',onpicked:setStartTime})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                       <input id="PmFinishDate"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'PmStartDate\')}',onpicked:setEndTime})" class="Wdate timeselect" />
                               </div>
                               <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                    <div id="multiple_condition_query" class="lr-query-wrap">
                                    <div class="lr-query-btn" id="spn_Search" style="font-size:10px;width:80px;">
                                        <i  class="fa fa-search"></i>&nbsp;多条件查询</>  
                                    </div>
                                    <div class="lr-query-content" style="width:750px;height:220px;" id="content">
                                         <div class="lr-query-formcontent" style="display:block"></div>
                                         <div class="lr-query-arrow">
                                             <div class="lr-query-inside"></div>
                                         </div>
                                         <div class="lr-query-content-bottom">
                                              <%--<a id="lr_btn_queryReset" class="btn btn-default">&nbsp;重&nbsp;&nbsp;置</a>--%>
                                              <a id="lr_btn_querySearch" class="btn btn-primary">&nbsp;查&nbsp;&nbsp;询</a>
                                         </div>
                                         <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">工序名称：</div>                                              <select class="form-control" id="ProcessName"></select>                                         </div>
                                         <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">设备名称：</div>                                              <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称">                                         </div>
                                         <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">保养类别：</div>                                              <select class="form-control" id="PmType">
                                                    <option value=''>请选择...</option>
                                                    <option value='计划内保养'>计划内保养</option>
                                                    <option value='计划外保养'>计划外保养</option>
                                              </select>                                          </div>
                                          <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">保养类型：</div>                                              <select class="form-control" id="PmLevel">
                                                   <option value=''>请选择...</option>
                                                   <option value='一级保养'>一级保养</option>
                                                   <option value='二级保养'>二级保养</option>
                                               </select>                                          </div>
                                          <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">执行情况：</div>                                              <select class="form-control" id="Status">
                                                   <option value=''>请选择...</option>
                                                   <option value='已完成'>已完成</option>
                                                   <option value='未完成'>未完成</option>
                                              </select>                                          </div>
                                          <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">保养规范：</div>                                              <input type="text" class="form-control" id="PmSpecName" placeholder="请输入保养规范名称">                                          </div>
                                          <div class=" col-xs-12 lr-form-item">                                              <div class="lr-form-item-title">保养计划：</div>                                              <input type="text" class="form-control" id="PmPlanName" placeholder="请输入保养计划名称">                                          </div>
                                     </div>
                                </div>
                                </div>
                                </div>
                                <div class=" lr-layout-tool-right">
                                    <div class="btn-group">
                                         <a id="btn_Add" class="btn btn-default" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建计划外保养</a>  
                                         <a id="btn_FirstLevel" class="btn btn-default"><i class="fa fa-edit"></i>一级保养维护</a>                        
                                         <a id="btn_SecondLevel" class="btn btn-default"><i class="fa fa-edit"></i>二级保养维护</a>
                                         <a id="btn_TotalTime" class="btn btn-default"><i class="fa fa-edit"></i>编辑生产停止时间</a>
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



