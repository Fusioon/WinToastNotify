using System;
using System.Interop;

using WinToastNotify.Win32;
using System.Collections;
using System.Reflection;

namespace WinToastNotify;

static
{
	public static Result<GUID> ParseUUID(StringView value)
	{
		if (value.Length != 36)
			return .Err;

		GUID guid;
		guid.data = Try!(uint32.Parse(value[0...7], .Hex));
		guid.data2 = Try!(uint16.Parse(value[9...12], .Hex));
		guid.data3 = Try!(uint16.Parse(value[14...17], .Hex));
		guid.data4[0] = Try!(uint8.Parse(value[19...20], .Hex));
		guid.data4[1] = Try!(uint8.Parse(value[21...22], .Hex));
		guid.data4[2] = Try!(uint8.Parse(value[24...25], .Hex));
		guid.data4[3] = Try!(uint8.Parse(value[26...27], .Hex));
		guid.data4[4] = Try!(uint8.Parse(value[28...29], .Hex));
		guid.data4[5] = Try!(uint8.Parse(value[30...31], .Hex));
		guid.data4[6] = Try!(uint8.Parse(value[32...33], .Hex));
		guid.data4[7] = Try!(uint8.Parse(value[34...35], .Hex));
		return guid;
	}
}


struct MIDL_INTERFACEAttribute : Attribute
{
	public readonly String UUID;
	public this(String guid)
	{
		UUID = guid;
	}
}

[MIDL_INTERFACE("00000000-0000-0000-C000-000000000046")]
interface IUnknown
{
	public HResult QueryInterface(in GUID riid, void** ppvObject);
	public c_ulong AddRef();
	public c_ulong Release();
}

[MIDL_INTERFACE("AF86E2E0-B12D-4c6a-9C5A-D7AA65101E90")]
interface IInspectable : IUnknown
{
	HResult GetIids(c_ulong* iidCount, GUID** iids);
	HResult GetRuntimeClassName(HSTRING* className);
	HResult GetTrustLevel(TrustLevel* trustLevel);
}

interface IReference<T> : IInspectable
	where T : struct
{
	HResult get_Value(T* value);
}	

[MIDL_INTERFACE("50ac103f-d235-4598-bbef-98fe4d1a3ad4")]
interface IToastNotificationManagerStatics : IInspectable
{
	HResult CreateToastNotifier(ComPtr<IToastNotifier>** result);
	HResult CreateToastNotifierWithId(HSTRING applicationId, ComPtr<IToastNotifier>** result);
	HResult GetTemplateContent(ToastTemplateType type, ComPtr<IXmlDocument>** result);
}

enum ToastTemplateType : c_int
{
    ToastImageAndText01 = 0,
    ToastImageAndText02 = 1,
    ToastImageAndText03 = 2,
    ToastImageAndText04 = 3,
    ToastText01 = 4,
    ToastText02 = 5,
    ToastText03 = 6,
    ToastText04 = 7,
}

enum NotificationSetting : c_int
{
    Enabled = 0,
    DisabledForApplication = 1,
    DisabledForUser = 2,
    DisabledByGroupPolicy = 3,
    DisabledByManifest = 4,
}

[MIDL_INTERFACE("75927b93-03f3-41ec-91d3-6e5bac1b38e7")]
interface IToastNotifier : IInspectable
{
	HResult Show(ComPtr<IToastNotification>* notification);
	HResult Hide(ComPtr<IToastNotification>* notification);
	HResult get_Setting(NotificationSetting* value);
	HResult AddToSchedule(ComPtr<IScheduledToastNotification>* scheduledToast);
	HResult RemoveFromSchedule(ComPtr<IScheduledToastNotification>* scheduledToast);
	HResult GetScheduledToastNotifications(__FIVectorView_1_Windows__CUI__CNotifications__CScheduledToastNotification** result);
}

[CRepr]
struct CDateTime
{
	public int64 UniversalTime;
}

[MIDL_INTERFACE("997e2675-059e-4e60-8b06-1760917c8b80")]
interface IToastNotification : IInspectable
{
	HResult get_Content(IXmlDocument** value);
	HResult put_ExpirationTime(ComPtr<IReference<CDateTime>>* value);
	HResult get_ExpirationTime(ComPtr<IReference<CDateTime>>** value);

	/*HResult add_Dismissed(__FITypedEventHandler_2_Windows__CUI__CNotifications__CToastNotification_Windows__CUI__CNotifications__CToastDismissedEventArgs* handler,    EventRegistrationToken* token);
	HResult remove_Dismissed(EventRegistrationToken token);
	HResult add_Activated(__FITypedEventHandler_2_Windows__CUI__CNotifications__CToastNotification_IInspectable* handler,    EventRegistrationToken* token);
	HResult remove_Activated(EventRegistrationToken token);
	HResult add_Failed(__FITypedEventHandler_2_Windows__CUI__CNotifications__CToastNotification_Windows__CUI__CNotifications__CToastFailedEventArgs* handler,    EventRegistrationToken* token);
	HResult remove_Failed(EventRegistrationToken token);*/

}

[MIDL_INTERFACE("f7f3a506-1e87-42d6-bcfb-b8c809fa5494")]
interface IXmlDocument : IInspectable
{
	HResult get_Doctype(ComPtr<IXmlDocumentType>** value);
	HResult get_Implementation(ComPtr<IXmlDomImplementation>** value);
	HResult get_DocumentElement(ComPtr<IXmlElement>** value);
	HResult CreateElement(HSTRING tagName, ComPtr<IXmlElement>** newElement);
	HResult CreateDocumentFragment(ComPtr<IXmlDocumentFragment>** newDocumentFragment);
	HResult CreateTextNode(HSTRING data, ComPtr<IXmlText>** newTextNode);
	HResult CreateComment(HSTRING data, ComPtr<IXmlComment>** newComment);
	HResult CreateProcessingInstruction(HSTRING target, HSTRING data, ComPtr<IXmlProcessingInstruction>** newProcessingInstruction);
	HResult CreateAttribute(HSTRING name, ComPtr<IXmlAttribute>** newAttribute);
	HResult CreateEntityReference(HSTRING name, ComPtr<IXmlEntityReference>** newEntityReference);
	HResult GetElementsByTagName(HSTRING tagName, ComPtr<IXmlNodeList>** elements);
	HResult CreateCDataSection(HSTRING data, ComPtr<IXmlCDataSection>** newCDataSection);
	HResult get_DocumentUri(HSTRING* value);
	HResult CreateAttributeNS(IInspectable* namespaceUri, HSTRING qualifiedName, ComPtr<IXmlAttribute>** newAttribute);
	HResult CreateElementNS(IInspectable* namespaceUri, HSTRING qualifiedName, ComPtr<IXmlElement>** newElement);
	HResult GetElementById(HSTRING elementId, ComPtr<IXmlElement>** element);
	HResult ImportNode(ComPtr<IXmlNode>* node, bool deep, ComPtr<IXmlNode>** newNode);

}

interface IXmlDocumentType : IInspectable
{

}

interface IXmlDomImplementation : IInspectable
{

}

interface IXmlElement : IInspectable
{

}

interface IXmlDocumentFragment : IInspectable
{

}


interface IXmlText : IInspectable
{

}

interface IXmlComment : IInspectable
{

}

interface IXmlProcessingInstruction : IInspectable
{

}

interface IXmlAttribute : IInspectable
{

}

interface IXmlEntityReference : IInspectable
{

}

interface IXmlNodeList : IInspectable
{

}

interface IXmlCDataSection : IInspectable
{

}

interface IXmlNode : IInspectable
{

}

[MIDL_INTERFACE("6cd0e74e-ee65-4489-9ebf-ca43e87ba637")]
interface IXmlDocumentIO : IInspectable
{
	HResult LoadXml(HSTRING xml);
	HResult LoadXmlWithSettings(HSTRING xml, ComPtr<IXmlLoadSettings>* loadSettings);
	HResult SaveToFileAsync(ComPtr<IStorageFile>* file, ComPtr<IAsyncAction>** asyncInfo);
}


interface IXmlLoadSettings : IInspectable
{

}

interface IStorageFile : IInspectable
{

}

interface IAsyncAction : IInspectable
{

}

[MIDL_INTERFACE("79f577f8-0de7-48cd-9740-9b370490c838")]
interface IScheduledToastNotification : IInspectable
{

}

[MIDL_INTERFACE("04124b20-82c6-4229-b109-fd9ed4662b53")]
interface IToastNotificationFactory : IInspectable
{
	HResult CreateToastNotification(ComPtr<IXmlDocument>* content, ComPtr<IToastNotification>** value);
}


struct ComVtbl<T>
	where T : interface, IUnknown
{
	typealias ThisT = void;//ComPtr<T>;

	[Comptime]
	static void GenerateType(Type type, String code, HashSet<TypeInstance> ifaces)
	{
		for (let i in type.Interfaces)
		{
			if (ifaces.Add(i))
				GenerateType(i, code, ifaces);
		}

		code.AppendF($"//{type.GetName(.. scope .())}\n");
		for (let m in  type.GetMethods())
		{
			if (m.GenericArgCount != 0)
				continue;

			String tmp = scope $"public function [CallingConvention(.Stdcall)] {m.ReturnType} (ThisT* This, ";
			let len = tmp.Length;
			m.GetParamsDecl(tmp);
			if (len == tmp.Length)
				tmp.Length -= 2;

			tmp.AppendF($") {m.Name};\n");

			code.Append(tmp);
		}
	}

	[Comptime, OnCompile(.TypeInit)]
	static void Generate()
	{
		String code = scope .();

		let type = typeof(T);
		GenerateType(type, code, scope .());
		
		Compiler.EmitTypeBody(typeof(Self), code);
	}
}

[CRepr]
struct ComPtr<T>
	where T : interface, IUnknown
{
	protected ComVtbl<T>* _vtbl;

	public Result<ComPtr<IfaceT>*, HResult> QueryInterface<IfaceT>() mut
		where IfaceT : interface, IUnknown
	{
		ComPtr<IfaceT>* pp = default;
		let result = ((ComVtbl<IUnknown>*)_vtbl).QueryInterface(&this, ComPtr<IfaceT>.IID, (.)&pp);
		if (result.Failed)
			return .Err(result);

		return .Ok(pp);
	}

	[Comptime]
	static void GenerateType(Type type, String code, HashSet<TypeInstance> ifaces)
	{
		for (let i in type.Interfaces)
		{
			if (ifaces.Add(i))
			{
				GenerateType(i, code, ifaces);
			}
		}

		for (let m in  type.GetMethods())
		{
			if (m.GenericArgCount != 0)
				continue;

			String tmp = scope $"public {m.ReturnType} {m.Name} (";
			m.GetParamsDecl(tmp);
			tmp.AppendF($") mut => _vtbl.{m.Name}(&this, ");
			if (m.ParamCount == 0)
				tmp.Length -= 2;
			m.GetArgsList(tmp);
			tmp.Append(");\n");

			code.Append(tmp);
		}
	}

	[Comptime, OnCompile(.TypeInit)]
	static void Generate()
	{
		String code = scope .();
		GenerateType(typeof(T), code, scope .());
		Compiler.EmitTypeBody(typeof(Self), code);
	}

	[Comptime(ConstEval=true)]
	static GUID GetUUID()
	{
		if (typeof(T).GetCustomAttribute<MIDL_INTERFACEAttribute>() case .Ok(let val))
		{
			return ParseUUID(val.UUID);
		}
		return default;
	}

	public static GUID IID = GetUUID();
}