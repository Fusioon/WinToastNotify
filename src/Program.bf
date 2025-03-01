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

[CRepr]
struct ComGenericVtbl<T> where T : struct
{
	public typealias ThisT = T;
	public function HResult(T* _this, IID* riid, void** ppvObject) QueryInterface;
	public function c_ulong (T* _this) AddRef;
	public function c_ulong (T* _this) Release;
}

[CRepr]
struct ComExGenericVtbl<T> : ComGenericVtbl<T> where T : struct
{
	public function HResult (T* This, c_ulong* iidCount, IID* iids) GetIids;
	public function HResult (T* This, HSTRING* className) GetRuntimeClassName;
	public function HResult (T* This, TrustLevel* trustLevel) GetTrustLevel;
}


[CRepr]
struct IUnknownVtbl : ComGenericVtbl<IGenericComObj>
{
	[CLink]
	public static extern readonly GUID IID_IUnknown;
}

[CRepr]
struct IClassFactoryVtbl : IUnknownVtbl
{
	public function HResult(IClassFactory* _this, IUnknown* pUnkOuter, GUID* riid, void** ppvObject) CreateInstance;
	public function HResult(IClassFactory* _this, Windows.IntBool fLock) LockServer;

	[CLink]
	public static extern readonly GUID IID_IClassFactory;

	public static Self Instance = .{
		QueryInterface = (_this, riid, ppvObject) => {
			if (*riid != IID_IClassFactory && *riid != IID_IUnknown)
			{
				*ppvObject = null;
				return EHResult.E_NOINTERFACE;
			}
			*ppvObject = _this;
			_this.lpVtbl.AddRef(_this);
			return EHResult.S_OK;
		},
		AddRef = => IGenericComObj.AddRef,
		Release = => IGenericComObj.Release,
		LockServer = (_this, fLock) => {
			return EHResult.S_OK;
		},
		CreateInstance = (_this, pUnkOuter, riid, ppvObject) => {

			if (pUnkOuter != null)
				return EHResult.CLASS_E_NOAGGREGATION;

			if (IGenericComObj* thisObj = (.)Internal.StdMalloc(sizeof(IGenericComObj)))
			{
				thisObj.lpVtbl = &INotificationActivationCallbackVtbl.Instance;
				thisObj.refCount = 1;
				let hr = thisObj.lpVtbl.QueryInterface(thisObj, riid, ppvObject);
				thisObj.lpVtbl.Release(thisObj);
				return hr;
			}

			return EHResult.E_OUTOFMEMORY;
		}
	};
}

[CRepr]
struct INotificationActivationCallbackVtbl : IUnknownVtbl
{
	[CRepr]
	public struct NOTIFICATION_USER_INPUT_DATA
	{
		public c_wchar* Key;
		public c_wchar* Value;
	}

	[CLink]
	public static extern readonly GUID IID_INotificationActivationCallback;

	public function HResult(INotificationActivationCallback* _this, c_wchar* appUserModelId, c_wchar* invokedArgs, NOTIFICATION_USER_INPUT_DATA* data, c_ulong count) Activate;

	public static Self Instance = .{
		QueryInterface = (_this, riid, ppvObject) => {
			if (*riid != IID_INotificationActivationCallback && *riid != IID_IUnknown)
			{
				*ppvObject = null;
				return EHResult.E_NOINTERFACE;
			}
			*ppvObject = _this;
			_this.lpVtbl.AddRef(_this);
			return EHResult.S_OK;
		},
		AddRef = => IGenericComObj.AddRef,
		Release = => IGenericComObj.Release,
		Activate = (_this, appUserModelId, invokedArgs, data, count) => {

			//PostThreadMessageW(dwMainThreadId, WM_QUIT, 0, 0);
			String args = scope .(invokedArgs);
			switch (args)
			{
			case "action=closeApp":
				{
					Program.PostThreadMessageW(Program.dwMainThreadId, WM_QUIT, 0, 0);
				}
			case "action=reply":
				{
					String reply = scope .();
					String key = scope .();
					for (let i < count)
					{
						key..Clear().Append(data[i].Key);
						if (key == "tbReply")
						{
							reply..Clear().Append(data.Value);
							Console.WriteLine($"Reply: {reply}");
						}
					}
				}
			default:
				Console.WriteLine(_);
			}
			return EHResult.S_OK;
		}
	};
}

[CRepr]
struct IClassFactory : IGenericComObj
{
	//public IClassFactoryVtbl* lpVtbl;
}

[CRepr]
struct INotificationActivationCallback : IGenericComObj
{
	
}

[CRepr]
struct IGenericComObj
{
	public IUnknownVtbl* lpVtbl;

	public uint64 refCount;

	public static c_ulong AddRef(Self* _this)
	{
		return (.)System.Threading.Interlocked.Increment(ref _this.refCount);
	}

	public static c_ulong Release(Self* _this)
	{
		return (.)System.Threading.Interlocked.Decrement(ref _this.refCount);
	}

}

[CRepr]
struct __x_ABI_CWindows_CUI_CNotifications_CIToastNotificationManagerStatics
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CIToastNotifier** result) CreateToastNotifier;
		public function HResult (ThisT* This, HSTRING applicationId, __x_ABI_CWindows_CUI_CNotifications_CIToastNotifier** result) CreateToastNotifierWithId;
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CToastTemplateType type, __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocument** result) GetTemplateContent;
	}

	public Vtbl* lpVtbl;
}

[CRepr]
struct __x_ABI_CWindows_CUI_CNotifications_CIToastNotifier
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CIToastNotification* notification) Show;
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CIToastNotification* notification) Hide;
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CNotificationSetting* value) get_Setting;
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CIScheduledToastNotification* scheduledToast) AddToSchedule;
		public function HResult (ThisT* This, __x_ABI_CWindows_CUI_CNotifications_CIScheduledToastNotification* scheduledToast) RemoveFromSchedule;
		public function HResult (ThisT* This, __FIVectorView_1_Windows__CUI__CNotifications__CScheduledToastNotification** result) GetScheduledToastNotifications;
	}
	public Vtbl* lpVtbl;
}

[CRepr]
struct __x_ABI_CWindows_CUI_CNotifications_CIToastNotificationFactory
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{
		public function HResult (ThisT* This, __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocument* content, __x_ABI_CWindows_CUI_CNotifications_CIToastNotification** value) CreateToastNotification;
	}

	public Vtbl* lpVtbl;
}

[CRepr]
struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocument
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{
		public function HResult (ThisT* This, __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentType** value) get_Doctype;
		public function HResult (ThisT* This, __x_ABI_CWindows_CData_CXml_CDom_CIXmlDomImplementation** value) get_Implementation;
		public function HResult (ThisT* This, __x_ABI_CWindows_CData_CXml_CDom_CIXmlElement** value) get_DocumentElement;
		public function HResult (ThisT* This, HSTRING tagName,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlElement** newElement) CreateElement;
		public function HResult (ThisT* This, __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentFragment** newDocumentFragment) CreateDocumentFragment;
		public function HResult (ThisT* This, HSTRING data,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlText** newTextNode) CreateTextNode;
		public function HResult (ThisT* This, HSTRING data,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlComment** newComment) CreateComment;
		public function HResult (ThisT* This, HSTRING target,    HSTRING data,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlProcessingInstruction** newProcessingInstruction) CreateProcessingInstruction;
		public function HResult (ThisT* This, HSTRING name,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlAttribute** newAttribute) CreateAttribute;
		public function HResult (ThisT* This, HSTRING name,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlEntityReference** newEntityReference) CreateEntityReference;
		public function HResult (ThisT* This, HSTRING tagName,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlNodeList** elements) GetElementsByTagName;
		public function HResult (ThisT* This, HSTRING data,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlCDataSection** newCDataSection) CreateCDataSection;
		public function HResult (ThisT* This, HSTRING* value) get_DocumentUri;
		public function HResult (ThisT* This, IInspectableC* namespaceUri,    HSTRING qualifiedName,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlAttribute** newAttribute) CreateAttributeNS;
		public function HResult (ThisT* This, IInspectableC* namespaceUri,    HSTRING qualifiedName,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlElement** newElement) CreateElementNS;
		public function HResult (ThisT* This, HSTRING elementId,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlElement** element) GetElementById;
		public function HResult (ThisT* This, __x_ABI_CWindows_CData_CXml_CDom_CIXmlNode* node, bool deep,    __x_ABI_CWindows_CData_CXml_CDom_CIXmlNode** newNode) ImportNode;
	}

	public Vtbl* lpVtbl;
}

[CRepr]
struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentIO
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{
		public function HResult (__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentIO* This, HSTRING xml) LoadXml;
		public function HResult (__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentIO* This, HSTRING xml, __x_ABI_CWindows_CData_CXml_CDom_CIXmlLoadSettings* loadSettings) LoadXmlWithSettings;
		public function HResult (__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentIO* This, __x_ABI_CWindows_CStorage_CIStorageFile* file, __x_ABI_CWindows_CFoundation_CIAsyncAction** asyncInfo) SaveToFileAsync;

	}

	public Vtbl* lpVtbl;
}

[CRepr]
struct __x_ABI_CWindows_CUI_CNotifications_CIToastNotification
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{

	}
	public Vtbl* lpVtbl;
}

[CRepr]
struct __x_ABI_CWindows_CUI_CNotifications_CIScheduledToastNotification
{
	public void* lpVtbl;
}

[CRepr]
struct __FIVectorView_1_Windows__CUI__CNotifications__CScheduledToastNotification
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentType
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlDomImplementation
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlElement
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentFragment
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlText
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlComment
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlProcessingInstruction
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlAttribute
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlEntityReference
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlNodeList
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlCDataSection
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlNode
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CData_CXml_CDom_CIXmlLoadSettings
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CStorage_CIStorageFile
{
	public void* lpVtbl;
}

struct __x_ABI_CWindows_CFoundation_CIAsyncAction
{
	public void* lpVtbl;
}

[CRepr]
struct IInspectableC
{
	[CRepr]
	public struct Vtbl : ComExGenericVtbl<SelfOuter>
	{ }
	public Vtbl* lpVtbl;
}


enum __x_ABI_CWindows_CUI_CNotifications_CToastTemplateType : c_int
{
	ToastTemplateType_ToastImageAndText01 = 0,
	ToastTemplateType_ToastImageAndText02 = 1,
	ToastTemplateType_ToastImageAndText03 = 2,
	ToastTemplateType_ToastImageAndText04 = 3,
	ToastTemplateType_ToastText01 = 4,
	ToastTemplateType_ToastText02 = 5,
	ToastTemplateType_ToastText03 = 6,
	ToastTemplateType_ToastText04 = 7,
}

enum __x_ABI_CWindows_CUI_CNotifications_CNotificationSetting : c_int
{
	NotificationSetting_Enabled = 0,
	NotificationSetting_DisabledForApplication = 1,
	NotificationSetting_DisabledForUser = 2,
	NotificationSetting_DisabledByGroupPolicy = 3,
	NotificationSetting_DisabledByManifest = 4,
}

[CRepr]
struct HSTRING_HEADER
{
	[CRepr, Union]
	public struct
	{
		public void* Reserved1;
#if BF_64_BIT
		c_char[24] Reserved2;
#else
		c_char[20] Reserved2;
#endif
	} Reserved;
}

struct HSTRING : int { }

enum TrustLevel : c_int
{
	BaseTrust,
	PartialTrust,
	FullTrust,
}

enum RO_INIT_TYPE : c_int
{
	RO_INIT_SINGLETHREADED     = 0,      // Single-threaded application
	RO_INIT_MULTITHREADED      = 1,      // COM calls objects on any thread.
}

enum COINITBASE : c_int
{
	COINITBASE_MULTITHREADED      = 0x0,      // OLE calls objects on any thread.
}

enum COINIT : c_int
{
  COINIT_APARTMENTTHREADED  = 0x2,      // Apartment model
  COINIT_MULTITHREADED      = COINITBASE.COINITBASE_MULTITHREADED,
  COINIT_DISABLE_OLE1DDE    = 0x4,      // Don't use DDE for Ole1 support.
  COINIT_SPEED_OVER_MEMORY  = 0x8,      // Trade memory for speed.
}

enum CLSCTX : c_int
{
	CLSCTX_INPROC_SERVER	= 0x1,
	CLSCTX_INPROC_HANDLER	= 0x2,
	CLSCTX_LOCAL_SERVER	= 0x4,
	CLSCTX_INPROC_SERVER16	= 0x8,
	CLSCTX_REMOTE_SERVER	= 0x10,
	CLSCTX_INPROC_HANDLER16	= 0x20,
	CLSCTX_RESERVED1	= 0x40,
	CLSCTX_RESERVED2	= 0x80,
	CLSCTX_RESERVED3	= 0x100,
	CLSCTX_RESERVED4	= 0x200,
	CLSCTX_NO_CODE_DOWNLOAD	= 0x400,
	CLSCTX_RESERVED5	= 0x800,
	CLSCTX_NO_CUSTOM_MARSHAL	= 0x1000,
	CLSCTX_ENABLE_CODE_DOWNLOAD	= 0x2000,
	CLSCTX_NO_FAILURE_LOG	= 0x4000,
	CLSCTX_DISABLE_AAA	= 0x8000,
	CLSCTX_ENABLE_AAA	= 0x10000,
	CLSCTX_FROM_DEFAULT_CONTEXT	= 0x20000,
	CLSCTX_ACTIVATE_X86_SERVER	= 0x40000,
#unwarn
	CLSCTX_ACTIVATE_32_BIT_SERVER	= CLSCTX_ACTIVATE_X86_SERVER,
	CLSCTX_ACTIVATE_64_BIT_SERVER	= 0x80000,
	CLSCTX_ENABLE_CLOAKING	= 0x100000,
	CLSCTX_APPCONTAINER	= 0x400000,
	CLSCTX_ACTIVATE_AAA_AS_IU	= 0x800000,
	CLSCTX_RESERVED6	= 0x01000000,
	CLSCTX_ACTIVATE_ARM32_SERVER	= 0x02000000,
	CLSCTX_ALLOW_LOWER_TRUST_REGISTRATION	= 0x04000000,
	CLSCTX_PS_DLL	= 0x80000000
}

enum REGCLS : c_int
{
	REGCLS_SINGLEUSE = 0,       // class object only generates one instance
	REGCLS_MULTIPLEUSE = 1,     // same class object genereates multiple inst.
	                            // and local automatically goes into inproc tbl.
	REGCLS_MULTI_SEPARATE = 2,  // multiple use, but separate control over each
	                            // context.
	REGCLS_SUSPENDED      = 4,  // register is as suspended, will be activated
	                            // when app calls CoResumeClassObjects
	REGCLS_SURROGATE      = 8,  // must be used when a surrogate process
	                            // is registering a class object that will be
	                            // loaded in the surrogate
	REGCLS_AGILE = 0x10,        // Class object aggregates the free-threaded marshaler
								// and will be made visible to all inproc apartments.
								// Can be used together with other flags - for example,
								// REGCLS_AGILE | REGCLS_MULTIPLEUSE to register a
								// class object that can be used multiple times from
								// different apartments. Without other flags, behavior
								// will retain REGCLS_SINGLEUSE semantics in that only
								// one instance can be generated.
}

class Program
{
	const String GUID_Impl_INotificationActivationCallback_Textual = "0F82E845-CB89-4039-BDBF-67CA33254C76";
	static GUID GUID_Impl_INotificationActivationCallback = .(0x0f82e845, 0xcb89, 0x4039, 0xbd, 0xbf, 0x67, 0xca, 0x33, 0x25, 0x4c, 0x76);

	const String APP_ID = "Beef Toast Example";
	const String TOAST_ACTIVATED_ARG = "-ToastActivated";

	static GUID IID_IToastNotificationManagerStatics = .(0x50ac103f, 0xd235, 0x4598, 0xbb, 0xef, 0x98, 0xfe, 0x4d, 0x1a, 0x3a, 0xd4);
	static GUID IID_IToastNotificationFactory = .(0x04124b20, 0x82c6, 0x4229, 0xb1, 0x09, 0xfd, 0x9e, 0xd4, 0x66, 0x2b, 0x53);
	static GUID IID_IXmlDocument = .(0xf7f3a506, 0x1e87, 0x42d6, 0xbc, 0xfb, 0xb8, 0xc8, 0x09, 0xfa, 0x54, 0x94);
	static GUID IID_IXmlDocumentIO = .(0x6cd0e74e, 0xee65, 0x4489, 0x9e, 0xbf, 0xca, 0x43, 0xe8, 0x7b, 0xa6, 0x37);

	const String RuntimeClass_Windows_UI_Notifications_ToastNotificationManager = "Windows.UI.Notifications.ToastNotificationManager";
	const String RuntimeClass_Windows_UI_Notifications_ToastNotification = "Windows.UI.Notifications.ToastNotification";
	const String RuntimeClass_Windows_Data_Xml_Dom_XmlDocument = "Windows.Data.Xml.Dom.XmlDocument";

	const String BannerText =
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

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult CoInitializeEx(void* pvReserved, c_ulong dwCoInit);

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult RoInitialize(RO_INIT_TYPE initType);

	[CLink, CallingConvention(.Stdcall)]
	static extern void RoUninitialize();

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult CoRegisterClassObject(IID* rclsid, IUnknown* pUnk, CLSCTX dwClsContext, REGCLS flags, c_ulong* lpdwRegister);

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult CoRevokeClassObject(c_ulong dwRegister);

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult RoGetActivationFactory(HSTRING activatableClassId, IID* iid, void** factory);

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult RoActivateInstance(HSTRING activatableClassId, void** instance);

	struct LSTATUS : c_long
	{
		const c_long FACILITY_WIN32 = 7;
		public HResult Result => (HResult)((this) <= 0 ? (this) : ((((c_long)this) & 0x0000FFFF) | (FACILITY_WIN32 << 16) | (c_long)0x80000000));
	}

	[CLink, CallingConvention(.Stdcall)]
	static extern LSTATUS RegSetValueW(HKey hkey, c_wchar* lpSubKey, c_ulong dwType, c_wchar* lpData, c_ulong cbData);

	static HResult SetRegistryValue(HKey hKey, StringView subKey, StringView data)
	{
		let subkeyWide = subKey.ToScopedNativeWChar!();
		let dataWide = data.ToScopedNativeWChar!(let dataSize);
		return RegSetValueW(hKey, subkeyWide, REG_SZ, dataWide.Ptr, (.)dataSize * sizeof(c_wchar)).Result;
	}

	static HResult SetRegistryKeyValue(HKey hKey, StringView subKey, StringView valueName, StringView data)
	{
		let subkeyWide = subKey.ToScopedNativeWChar!();
		let valuekeyWide = valueName.ToScopedNativeWChar!();
		let dataWide = data.ToScopedNativeWChar!(let dataSize);
		return ((LSTATUS)RegSetKeyValueW(hKey, subkeyWide, valuekeyWide, REG_SZ, dataWide.Ptr, (.)dataSize * sizeof(c_wchar))).Result;
	}

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult WindowsCreateStringReference(c_wchar* sourceString, c_uint length, HSTRING_HEADER* hstringHeader, HSTRING* string);

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult WindowsCreateString(c_wchar* sourceString, c_uint length, HSTRING* string);

	[CLink, CallingConvention(.Stdcall)]
	static extern HResult WindowsDeleteString(HSTRING string);

	static Result<HSTRING, HResult> ReferenceString<CString>(CString data, out HSTRING_HEADER hStringHeader) where CString : const String
	{
		static c_wchar[?] wide = CString.ToConstNativeW();
		hStringHeader = default;
		HSTRING hString = 0;
		#unwarn
		let result = WindowsCreateStringReference(&wide, (.)CString.Length, &hStringHeader, &hString);
		if (result.Success)
		{
			return .Ok(hString);
		}
		return .Err(result);
	}


	[CLink, CallingConvention(.Stdcall)]
	static extern c_ulong GetCurrentThreadId();

	public static c_ulong dwMainThreadId;

	[CLink, CallingConvention(.Stdcall)]
	public static extern Windows.IntBool PostThreadMessageW(c_ulong idThread, c_uint Msg, c_uintptr wParam, c_intptr lParam);

	static mixin CheckResult(HResult result, bool allowModeChange = false)
	{
		const int32 RPC_E_CHANGED_MODE = (.)0x80010106L;

		if (result.Failed && (!allowModeChange || result != (.)RPC_E_CHANGED_MODE))
		{
			Console.WriteLine($"{((uint32)result):x}");
			return;
		}
	}

	static mixin CheckResultVal<T>(Result<T, HResult> result)
	{
		if (result case .Err(let code))
		{
			Console.WriteLine($"{((uint32)code):x}");
			return;
		}

		result.Get()
	}

	static void Main(String[] args)
	{
		dwMainThreadId = GetCurrentThreadId();
		bool fromToast = false;
		for (let a in args)
		{
			if (a == TOAST_ACTIVATED_ARG)
			{
				fromToast = true;
				break;
			}
		}

		if (fromToast)
			return;

		CheckResult!(CoInitializeEx(null, COINIT.COINIT_MULTITHREADED.Underlying), true);
		defer CoUninitialize();
		CheckResult!(RoInitialize(.RO_INIT_MULTITHREADED), true);
		defer RoUninitialize();

		let pClassFactory = (IGenericComObj*)Internal.StdMalloc(sizeof(IGenericComObj));
		pClassFactory.lpVtbl = &IClassFactoryVtbl.Instance;
		pClassFactory.refCount = 1;

		uint32 dwCookie = 0;
		CheckResult!(CoRegisterClassObject(&GUID_Impl_INotificationActivationCallback, (.)pClassFactory, .CLSCTX_LOCAL_SERVER, .REGCLS_MULTIPLEUSE, &dwCookie));
		defer CoRevokeClassObject(dwCookie);

		{
			String value = scope .();
			value.Append('\"');
			//Environment.GetExecutableFilePath(value);
			c_wchar[Windows.MAX_PATH] buffer = default;
			GetModuleFileNameW(0, &buffer, Windows.MAX_PATH);
			value.Append(&buffer);
			value.Append('\"');
			value.AppendF($" {TOAST_ACTIVATED_ARG}");

			const String LocalServerKey = @$"SOFTWARE\Classes\CLSID\{GUID_Impl_INotificationActivationCallback_Textual}\LocalServer32";
			CheckResult!(SetRegistryValue(HKEY_CURRENT_USER, LocalServerKey, value));
		}

		{
			const String key = @$"SOFTWARE\Classes\AppUserModelId\{APP_ID}";

			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "DisplayName", "Beef Toast Activator Example"));
			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "IconBackgroundColor", "FF00FF00"));
			const String ACTIVATOR_GUID = $"{{{GUID_Impl_INotificationActivationCallback_Textual}}}";
			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "CustomActivator", ACTIVATOR_GUID));
		}
		let hsAppId = ReferenceString(APP_ID, let hshAppId).Value;
		defer WindowsDeleteString(hsAppId);

		let hsToastNotificationManager = ReferenceString(RuntimeClass_Windows_UI_Notifications_ToastNotificationManager, let hshToasNotificationManager).Value;
		defer WindowsDeleteString(hsToastNotificationManager);

		ComPtr<IToastNotificationManagerStatics>* pToastNotificationManager = null;
		CheckResult!(RoGetActivationFactory(hsToastNotificationManager, &ComPtr<IToastNotificationManagerStatics>.IID, (.)&pToastNotificationManager));
		defer pToastNotificationManager.Release();

		ComPtr<IToastNotifier>* pToastNotifier = null;
		CheckResult!(pToastNotificationManager.CreateToastNotifierWithId(hsAppId, &pToastNotifier));
		defer pToastNotifier.Release();

		let hsToastNotification = ReferenceString(RuntimeClass_Windows_UI_Notifications_ToastNotification, let hshToastNotification).Value;
		defer WindowsDeleteString(hsToastNotification);

		ComPtr<IToastNotificationFactory>* pNotificationFactory = null;
		CheckResult!(RoGetActivationFactory(hsToastNotification, &IID_IToastNotificationFactory, (.)&pNotificationFactory));
		defer pNotificationFactory.Release();

		let hsXmlDocument = ReferenceString(RuntimeClass_Windows_Data_Xml_Dom_XmlDocument, let hshXmlDocument).Value;
		defer WindowsDeleteString(hsXmlDocument);

		ComPtr<IInspectable>* pInspectable = null;
		CheckResult!(RoActivateInstance(hsXmlDocument, (.)&pInspectable));
		defer pInspectable.Release();

		var pXmlDocument = CheckResultVal!(pInspectable.QueryInterface<IXmlDocument>());
		defer pXmlDocument.Release();

		var pXmlDocumentIO = CheckResultVal!(pXmlDocument.QueryInterface<IXmlDocumentIO>());
		defer pXmlDocumentIO.Release();

		let hsBanner = ReferenceString(BannerText, let hshBanner).Value;
		defer WindowsDeleteString(hsBanner);

		CheckResult!(pXmlDocumentIO.LoadXml(hsBanner));

		ComPtr<IToastNotification>* pToastNotification = null;
		CheckResult!(pNotificationFactory.CreateToastNotification(pXmlDocument, &pToastNotification));
		defer pToastNotification.Release();

		CheckResult!(pToastNotifier.Show(pToastNotification));

		MSG msg = default;
		while (GetMessageW(&msg, 0, 0, 0) > 0)
		{
			TranslateMessage(&msg);
			DispatchMessageW(&msg);
		}
	}

	static void Main2(String[] args)
	{
		dwMainThreadId = GetCurrentThreadId();
		bool fromToast = false;
		for (let a in args)
		{
			if (a == TOAST_ACTIVATED_ARG)
			{
				fromToast = true;
				break;
			}
		}

		if (fromToast)
			return;

		CheckResult!(CoInitializeEx(null, COINIT.COINIT_MULTITHREADED.Underlying), true);
		defer CoUninitialize();
		CheckResult!(RoInitialize(.RO_INIT_MULTITHREADED), true);
		defer RoUninitialize();

		let pClassFactory = (IGenericComObj*)Internal.StdMalloc(sizeof(IGenericComObj));
		pClassFactory.lpVtbl = &IClassFactoryVtbl.Instance;
		pClassFactory.refCount = 1;

		uint32 dwCookie = 0;
		CheckResult!(CoRegisterClassObject(&GUID_Impl_INotificationActivationCallback, (.)pClassFactory, .CLSCTX_LOCAL_SERVER, .REGCLS_MULTIPLEUSE, &dwCookie));
		defer CoRevokeClassObject(dwCookie);

		{
			String value = scope .();
			value.Append('\"');
			//Environment.GetExecutableFilePath(value);
			c_wchar[Windows.MAX_PATH] buffer = default;
			GetModuleFileNameW(0, &buffer, Windows.MAX_PATH);
			value.Append(&buffer);
			value.Append('\"');
			value.AppendF($" {TOAST_ACTIVATED_ARG}");

			const String LocalServerKey = @$"SOFTWARE\Classes\CLSID\{GUID_Impl_INotificationActivationCallback_Textual}\LocalServer32";
			CheckResult!(SetRegistryValue(HKEY_CURRENT_USER, LocalServerKey, value));
		}

		{
			const String key = @$"SOFTWARE\Classes\AppUserModelId\{APP_ID}";

			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "DisplayName", "Beef Toast Activator Example"));
			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "IconBackgroundColor", "FF00FF00"));
			const String ACTIVATOR_GUID = $"{{{GUID_Impl_INotificationActivationCallback_Textual}}}";
			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "CustomActivator", ACTIVATOR_GUID));
		}
		let hsAppId = ReferenceString(APP_ID, let hshAppId).Value;
		defer WindowsDeleteString(hsAppId);

		let hsToastNotificationManager = ReferenceString(RuntimeClass_Windows_UI_Notifications_ToastNotificationManager, let hshToasNotificationManager).Value;
		defer WindowsDeleteString(hsToastNotificationManager);

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotificationManagerStatics* pToastNotificationManager = null;
		CheckResult!(RoGetActivationFactory(hsToastNotificationManager, &IID_IToastNotificationManagerStatics, (.)&pToastNotificationManager));
		defer pToastNotificationManager.lpVtbl.Release(pToastNotificationManager);

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotifier* pToastNotifier = null;
		CheckResult!(pToastNotificationManager.lpVtbl.CreateToastNotifierWithId(pToastNotificationManager, hsAppId, &pToastNotifier));
		defer pToastNotifier.lpVtbl.Release(pToastNotifier);

		let hsToastNotification = ReferenceString(RuntimeClass_Windows_UI_Notifications_ToastNotification, let hshToastNotification).Value;
		defer WindowsDeleteString(hsToastNotification);

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotificationFactory* pNotificationFactory = null;
		CheckResult!(RoGetActivationFactory(hsToastNotification, &IID_IToastNotificationFactory, (.)&pNotificationFactory));
		defer pNotificationFactory.lpVtbl.Release(pNotificationFactory);

		let hsXmlDocument = ReferenceString(RuntimeClass_Windows_Data_Xml_Dom_XmlDocument, let hshXmlDocument).Value;
		defer WindowsDeleteString(hsXmlDocument);

		IInspectableC* pInspectable = null;
		CheckResult!(RoActivateInstance(hsXmlDocument, (.)&pInspectable));
		defer pInspectable.lpVtbl.Release(pInspectable);

		__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocument* pXmlDocument = null;
		CheckResult!(pInspectable.lpVtbl.QueryInterface(pInspectable, &IID_IXmlDocument, (.)&pXmlDocument));
		defer pXmlDocument.lpVtbl.Release(pXmlDocument);

		__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentIO* pXmlDocumentIO = null;
		CheckResult!(pXmlDocument.lpVtbl.QueryInterface(pXmlDocument, &IID_IXmlDocumentIO, (.)&pXmlDocumentIO));
		defer pXmlDocumentIO.lpVtbl.Release(pXmlDocumentIO);

		let hsBanner = ReferenceString(BannerText, let hshBanner).Value;
		defer WindowsDeleteString(hsBanner);
		
		CheckResult!(pXmlDocumentIO.lpVtbl.LoadXml(pXmlDocumentIO, hsBanner));

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotification* pToastNotification = null;
		CheckResult!(pNotificationFactory.lpVtbl.CreateToastNotification(pNotificationFactory, pXmlDocument, &pToastNotification));
		defer pToastNotification.lpVtbl.Release(pToastNotification);

		CheckResult!(pToastNotifier.lpVtbl.Show(pToastNotifier, pToastNotification));

		MSG msg = default;
		while (GetMessageW(&msg, 0, 0, 0) > 0)
		{
			TranslateMessage(&msg);
			DispatchMessageW(&msg);
		}
	}
}