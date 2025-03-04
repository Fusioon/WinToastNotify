using System;
using System.Interop;

using WinToastNotify.Win32;

namespace WinToastNotify;

typealias IID = GUID;

enum EHResult : c_long
{
	case S_OK = 0;
	case E_OUTOFMEMORY = 0x8007000EL;
	case E_NOINTERFACE = 0x80004002;
	case CLASS_E_NOAGGREGATION = 0x80040110L;

	public static implicit operator HResult(Self inst)
	{
		return ((.)(c_long)inst);
	}
}


static
{
	public static mixin CheckResult(HResult result, bool allowModeChange = false)
	{
		const int32 RPC_E_CHANGED_MODE = (.)0x80010106L;

		if (result.Failed && (!allowModeChange || result != (.)RPC_E_CHANGED_MODE))
		{
			Console.WriteLine($"{((uint32)result):x}");
			return;
		}
	}

	public static mixin CheckResultVal<T>(Result<T, HResult> result)
	{
		if (result case .Err(let code))
		{
			Console.WriteLine($"{((uint32)code):x}");
			return;
		}

		result.Get()
	}
}

class Common
{
	public const String GUID_Impl_INotificationActivationCallback_Textual = "0F82E845-CB89-4039-BDBF-67CA33254C76";
	public static GUID GUID_Impl_INotificationActivationCallback = .(0x0f82e845, 0xcb89, 0x4039, 0xbd, 0xbf, 0x67, 0xca, 0x33, 0x25, 0x4c, 0x76);

	public const String APP_ID = "Beef Toast Example";
	public const String TOAST_ACTIVATED_ARG = "-ToastActivated";

	public static GUID IID_IToastNotificationManagerStatics = .(0x50ac103f, 0xd235, 0x4598, 0xbb, 0xef, 0x98, 0xfe, 0x4d, 0x1a, 0x3a, 0xd4);
	public static GUID IID_IToastNotificationFactory = .(0x04124b20, 0x82c6, 0x4229, 0xb1, 0x09, 0xfd, 0x9e, 0xd4, 0x66, 0x2b, 0x53);
	public static GUID IID_IXmlDocument = .(0xf7f3a506, 0x1e87, 0x42d6, 0xbc, 0xfb, 0xb8, 0xc8, 0x09, 0xfa, 0x54, 0x94);
	public static GUID IID_IXmlDocumentIO = .(0x6cd0e74e, 0xee65, 0x4489, 0x9e, 0xbf, 0xca, 0x43, 0xe8, 0x7b, 0xa6, 0x37);

	public const String RuntimeClass_Windows_UI_Notifications_ToastNotificationManager = "Windows.UI.Notifications.ToastNotificationManager";
	public const String RuntimeClass_Windows_UI_Notifications_ToastNotification = "Windows.UI.Notifications.ToastNotification";
	public const String RuntimeClass_Windows_Data_Xml_Dom_XmlDocument = "Windows.Data.Xml.Dom.XmlDocument";

	public const String BannerText =
	"""
	<toast scenario="reminder"
	activationType="foreground" launch="action=mainContent" duration="short">
		<visual>
			<binding template="ToastGeneric">
				<text><![CDATA[Test notification]]></text>
				<text><![CDATA[With 2 lines of text]]></text>
				<text placement="attribution"><![CDATA[Based on work of Valentin-Gabriel Radu (github.com/valinet)]]></text>
			</binding>
		</visual>
	  <actions>
		  <input id="tbReply" type="text" placeHolderContent="Send a message to the app"/>
		  <action content="Send" activationType="foreground" arguments="action=reply"/>
		  <action content="Close app" activationType="foreground" arguments="action=closeApp"/>
	  </actions>
		<audio src="ms-winsoundevent:Notification.Default" loop="false" silent="false"/>
	</toast>
	""";

	const bool RUN_C_Example = false;

	static int Main(String[] args)
	{
		if (RUN_C_Example)
		{
			Program_C.Main(args);
		}
		else
		{
			Program_Beef.Main(args);
		}
		return 0;
	}
}