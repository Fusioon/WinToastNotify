using System;
using System.Interop;

using WinToastNotify.Win32;

namespace WinToastNotify;

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
					PostThreadMessageW(Program_C.dwMainThreadId, WM_QUIT, 0, 0);
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

class Program_C
{
	public static c_ulong dwMainThreadId;

	public static void Main(String[] args)
	{
		dwMainThreadId = GetCurrentThreadId();
		bool fromToast = false;
		for (let a in args)
		{
			if (a == Common.TOAST_ACTIVATED_ARG)
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
		CheckResult!(CoRegisterClassObject(&Common.GUID_Impl_INotificationActivationCallback, (.)pClassFactory, .CLSCTX_LOCAL_SERVER, .REGCLS_MULTIPLEUSE, &dwCookie));
		defer CoRevokeClassObject(dwCookie);

		{
			String value = scope .();
			value.Append('\"');
			//Environment.GetExecutableFilePath(value);
			c_wchar[Windows.MAX_PATH] buffer = default;
			GetModuleFileNameW(0, &buffer, Windows.MAX_PATH);
			value.Append(&buffer);
			value.Append('\"');
			value.AppendF($" {Common.TOAST_ACTIVATED_ARG}");

			const String LocalServerKey = @$"SOFTWARE\Classes\CLSID\{Common.GUID_Impl_INotificationActivationCallback_Textual}\LocalServer32";
			CheckResult!(SetRegistryValue(HKEY_CURRENT_USER, LocalServerKey, value));
		}

		{
			const String key = @$"SOFTWARE\Classes\AppUserModelId\{Common.APP_ID}";

			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "DisplayName", "Beef Toast Activator Example"));
			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "IconBackgroundColor", "FF00FF00"));
			const String ACTIVATOR_GUID = $"{{{Common.GUID_Impl_INotificationActivationCallback_Textual}}}";
			CheckResult!(SetRegistryKeyValue(HKEY_CURRENT_USER, key,  "CustomActivator", ACTIVATOR_GUID));
		}
		let hsAppId = ReferenceString(Common.APP_ID, let hshAppId).Value;
		defer WindowsDeleteString(hsAppId);

		let hsToastNotificationManager = ReferenceString(Common.RuntimeClass_Windows_UI_Notifications_ToastNotificationManager, let hshToasNotificationManager).Value;
		defer WindowsDeleteString(hsToastNotificationManager);

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotificationManagerStatics* pToastNotificationManager = null;
		CheckResult!(RoGetActivationFactory(hsToastNotificationManager, &Common.IID_IToastNotificationManagerStatics, (.)&pToastNotificationManager));
		defer pToastNotificationManager.lpVtbl.Release(pToastNotificationManager);

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotifier* pToastNotifier = null;
		CheckResult!(pToastNotificationManager.lpVtbl.CreateToastNotifierWithId(pToastNotificationManager, hsAppId, &pToastNotifier));
		defer pToastNotifier.lpVtbl.Release(pToastNotifier);

		let hsToastNotification = ReferenceString(Common.RuntimeClass_Windows_UI_Notifications_ToastNotification, let hshToastNotification).Value;
		defer WindowsDeleteString(hsToastNotification);

		__x_ABI_CWindows_CUI_CNotifications_CIToastNotificationFactory* pNotificationFactory = null;
		CheckResult!(RoGetActivationFactory(hsToastNotification, &Common.IID_IToastNotificationFactory, (.)&pNotificationFactory));
		defer pNotificationFactory.lpVtbl.Release(pNotificationFactory);

		let hsXmlDocument = ReferenceString(Common.RuntimeClass_Windows_Data_Xml_Dom_XmlDocument, let hshXmlDocument).Value;
		defer WindowsDeleteString(hsXmlDocument);

		IInspectableC* pInspectable = null;
		CheckResult!(RoActivateInstance(hsXmlDocument, (.)&pInspectable));
		defer pInspectable.lpVtbl.Release(pInspectable);

		__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocument* pXmlDocument = null;
		CheckResult!(pInspectable.lpVtbl.QueryInterface(pInspectable, &Common.IID_IXmlDocument, (.)&pXmlDocument));
		defer pXmlDocument.lpVtbl.Release(pXmlDocument);

		__x_ABI_CWindows_CData_CXml_CDom_CIXmlDocumentIO* pXmlDocumentIO = null;
		CheckResult!(pXmlDocument.lpVtbl.QueryInterface(pXmlDocument, &Common.IID_IXmlDocumentIO, (.)&pXmlDocumentIO));
		defer pXmlDocumentIO.lpVtbl.Release(pXmlDocumentIO);

		let hsBanner = ReferenceString(Common.BannerText, let hshBanner).Value;
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