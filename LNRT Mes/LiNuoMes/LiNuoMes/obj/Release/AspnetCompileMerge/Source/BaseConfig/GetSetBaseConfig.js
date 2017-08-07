//功能: 设定或者读取MES系统基本参数
//ParamName: 参数名称
//ParamValue: 参数值
//ReadWrite: 读取: READ; 设置:WRITE
//回调函数句柄, 句柄定义:function callbackFunc(data){}; data: 设定或读取后参数值
function g_getSetParam(ParamName, ParamValue, ReadWrite, callbackFunc) {
    $.ajax({
        url: "..\\BaseConfig\\GetSetBaseConfig.ashx",
        data: {
            Action: "MES_CONFIG",
            ReadWriteFlag: ReadWrite,
            ID: "1",
            ParamName: ParamName,
            ParamValue: ParamValue
        },
        type: "post",
        datatype: "json",
        success: function (data) {
            data = JSON.parse(data);
            if (data.result == "success") {
                callbackFunc(data.ParamValue);
            }
            else if (data.result == "failed") {
                dialogMsg(data.msg, -1);
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            dialogMsg(errorThrown, -1);
        },
        beforeSend: function () {
        },
        complete: function () {
        }
    });

}
