using System;
using System.Interop;

using WinToastNotify.Win32;

namespace WinToastNotify;

class Program_Beef
{
#region COM_INTERFACES

	[MIDL_INTERFACE("50ac103f-d235-4598-bbef-98fe4d1a3ad4")]
	public interface IToastNotificationManagerStatics : IInspectable
	{
		HResult CreateToastNotifier(ComPtr<IToastNotifier>** result);
		HResult CreateToastNotifierWithId(HSTRING applicationId, ComPtr<IToastNotifier>** result);
		HResult GetTemplateContent(ToastTemplateType type, ComPtr<IXmlDocument>** result);
	}

	public enum ToastTemplateType : c_int
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

	public enum NotificationSetting : c_int
	{
	    Enabled = 0,
	    DisabledForApplication = 1,
	    DisabledForUser = 2,
	    DisabledByGroupPolicy = 3,
	    DisabledByManifest = 4,
	}

	[MIDL_INTERFACE("75927b93-03f3-41ec-91d3-6e5bac1b38e7")]
	public interface IToastNotifier : IInspectable
	{
		HResult Show(ComPtr<IToastNotification>* notification);
		HResult Hide(ComPtr<IToastNotification>* notification);
		HResult get_Setting(NotificationSetting* value);
		HResult AddToSchedule(ComPtr<IScheduledToastNotification>* scheduledToast);
		HResult RemoveFromSchedule(ComPtr<IScheduledToastNotification>* scheduledToast);
		HResult GetScheduledToastNotifications(__FIVectorView_1_Windows__CUI__CNotifications__CScheduledToastNotification** result);
	}

	[CRepr]
	public struct CDateTime
	{
		public int64 UniversalTime;
	}

	[MIDL_INTERFACE("997e2675-059e-4e60-8b06-1760917c8b80")]
	public interface IToastNotification : IInspectable
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
	public interface IXmlDocument : IInspectable
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

	public interface IXmlDocumentType : IInspectable
	{

	}

	public interface IXmlDomImplementation : IInspectable
	{

	}

	public interface IXmlElement : IInspectable
	{

	}

	public interface IXmlDocumentFragment : IInspectable
	{

	}


	public interface IXmlText : IInspectable
	{

	}

	public interface IXmlComment : IInspectable
	{

	}

	public interface IXmlProcessingInstruction : IInspectable
	{

	}

	public interface IXmlAttribute : IInspectable
	{

	}

	public interface IXmlEntityReference : IInspectable
	{

	}

	public interface IXmlNodeList : IInspectable
	{

	}

	public interface IXmlCDataSection : IInspectable
	{

	}

	public interface IXmlNode : IInspectable
	{

	}

	[MIDL_INTERFACE("6cd0e74e-ee65-4489-9ebf-ca43e87ba637")]
	public interface IXmlDocumentIO : IInspectable
	{
		HResult LoadXml(HSTRING xml);
		HResult LoadXmlWithSettings(HSTRING xml, ComPtr<IXmlLoadSettings>* loadSettings);
		HResult SaveToFileAsync(ComPtr<IStorageFile>* file, ComPtr<IAsyncAction>** asyncInfo);
	}


	public interface IXmlLoadSettings : IInspectable
	{

	}

	public interface IStorageFile : IInspectable
	{

	}

	public interface IAsyncAction : IInspectable
	{

	}

	[MIDL_INTERFACE("79f577f8-0de7-48cd-9740-9b370490c838")]
	public interface IScheduledToastNotification : IInspectable
	{

	}

	[MIDL_INTERFACE("04124b20-82c6-4229-b109-fd9ed4662b53")]
	public interface IToastNotificationFactory : IInspectable
	{
		HResult CreateToastNotification(ComPtr<IXmlDocument>* content, ComPtr<IToastNotification>** value);
	}


#endregion


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

	[GenerateVTable]
	public struct GenericComPtr : ComPtr
	{
		public uint64 refCount = 0;

		public HResult QueryInterface(IID* riid, void** ppvObject) mut
		{
			return EHResult.E_NOINTERFACE;
		}

		public c_ulong AddRef() mut
		{
			return (.)System.Threading.Interlocked.Increment(ref refCount);
		}

		public c_ulong Release() mut
		{
			return (.)System.Threading.Interlocked.Decrement(ref refCount);
		}
	}

	[GenerateVTable]
	public struct INotificationActivationCallback : GenericComPtr
	{
		[CRepr]
		public struct NOTIFICATION_USER_INPUT_DATA
		{
			public c_wchar* Key;
			public c_wchar* Value;
		}

		[CLink]
		public static extern readonly GUID IID_INotificationActivationCallback;

		public new HResult QueryInterface(IID* riid, void** ppvObject) mut
		{
			if (*riid != IID_INotificationActivationCallback && *riid != ComPtr<IUnknown>.IID)
			{
				*ppvObject = null;
				return EHResult.E_NOINTERFACE;
			}
			*ppvObject = &this;
			AddRef();
			return EHResult.S_OK;
		}

		public HResult Activate(c_wchar* appUserModelId, c_wchar* invokedArgs, NOTIFICATION_USER_INPUT_DATA* data, c_ulong count) mut
		{
			String args = scope .(invokedArgs);
			switch (args)
			{
			case "action=closeApp":
				{
					PostThreadMessageW(dwMainThreadId, WM_QUIT, 0, 0);
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
	}

	[GenerateVTable]
	public struct IClassFactory : GenericComPtr
	{
		[CLink]
		public static extern readonly GUID IID_IClassFactory;

		public new HResult QueryInterface(IID* riid, void** ppvObject) mut
		{
			 if (*riid != IID_IClassFactory && *riid != ComPtr<IUnknown>.IID)
			{
				*ppvObject = null;
				return EHResult.E_NOINTERFACE;
			}
			*ppvObject = &this;
			AddRef();
			return EHResult.S_OK;
		}

		
		public HResult CreateInstance(ComPtr<IUnknown>* pUnkOuter, GUID* riid, void** ppvObject) mut
		{
			if (pUnkOuter != null)
				return EHResult.CLASS_E_NOAGGREGATION;

			if (INotificationActivationCallback* thisObj = (.)Internal.StdMalloc(sizeof(INotificationActivationCallback)))
			{
				*thisObj = .();
				thisObj.refCount = 1;
				let hr = thisObj.QueryInterface(riid, ppvObject);
				thisObj.Release();
				return hr;
			}

			return EHResult.E_OUTOFMEMORY;
		}

		public HResult LockServer(Windows.IntBool fLock) mut => EHResult.S_OK;
	}

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

		let pClassFactory = (IClassFactory*)Internal.StdMalloc(sizeof(IClassFactory));
		*pClassFactory = .();
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

		ComPtr<IToastNotificationManagerStatics>* pToastNotificationManager = null;
		CheckResult!(RoGetActivationFactory(hsToastNotificationManager, &ComPtr<IToastNotificationManagerStatics>.IID, (.)&pToastNotificationManager));
		defer pToastNotificationManager.Release();

		ComPtr<IToastNotifier>* pToastNotifier = null;
		CheckResult!(pToastNotificationManager.CreateToastNotifierWithId(hsAppId, &pToastNotifier));
		defer pToastNotifier.Release();

		let hsToastNotification = ReferenceString(Common.RuntimeClass_Windows_UI_Notifications_ToastNotification, let hshToastNotification).Value;
		defer WindowsDeleteString(hsToastNotification);

		ComPtr<IToastNotificationFactory>* pNotificationFactory = null;
		CheckResult!(RoGetActivationFactory(hsToastNotification, &Common.IID_IToastNotificationFactory, (.)&pNotificationFactory));
		defer pNotificationFactory.Release();

		let hsXmlDocument = ReferenceString(Common.RuntimeClass_Windows_Data_Xml_Dom_XmlDocument, let hshXmlDocument).Value;
		defer WindowsDeleteString(hsXmlDocument);

		ComPtr<IInspectable>* pInspectable = null;
		CheckResult!(RoActivateInstance(hsXmlDocument, (.)&pInspectable));
		defer pInspectable.Release();

		var pXmlDocument = CheckResultVal!(pInspectable.QueryInterface<IXmlDocument>());
		defer pXmlDocument.Release();

		var pXmlDocumentIO = CheckResultVal!(pXmlDocument.QueryInterface<IXmlDocumentIO>());
		defer pXmlDocumentIO.Release();

		let hsBanner = ReferenceString(Common.BannerText, let hshBanner).Value;
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
}