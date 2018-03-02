#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>

#include "maid3.h"
#include "maid3d1.h"
#include "CtrlSample.h"
#include "jpeglib\jpeglib.h"

BOOL init_module();
BOOL close_module();
BOOL init_camera();
BOOL close_camera();

BOOL set_saveonDRAM();
BOOL set_compression_level(ULONG lev);
BOOL SetLiveView_status(ULONG st);

BOOL capture();
BOOL get_image();
unsigned char* GetLiveViewImage(mwSize* dim);

void exit_routine();

LPMAIDEntryPointProc	g_pMAIDEntryPoint = NULL;
UCHAR	g_bFileRemoved = false;
ULONG	g_ulCameraType = 0;

ULONG *ulSrcID; //Camera Child ID from Module
LPRefObj	pRefMod1; //Module handler
LPRefObj pRefSrc1; //Camera handler

HINSTANCE	*g_hInstModule;

static BOOL isCameraOpen = false;


//JPEG ERROR MANAGEMENT
struct my_error_mgr {
  struct jpeg_error_mgr pub;    /* "public" fields */
  jmp_buf setjmp_buffer;        /* for return to caller */
};

typedef struct my_error_mgr *my_error_ptr;

METHODDEF(void)
my_error_exit (j_common_ptr cinfo)
{
  my_error_ptr myerr = (my_error_ptr) cinfo->err;
  (*cinfo->err->output_message) (cinfo);
  longjmp(myerr->setjmp_buffer, 1);
}
//************************************************************************

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
    BOOL ok;
    unsigned char *RGBimage, *outMatrix;
    char *in_str,n_str;
    mwSize out_dim[3];
    int i,j,k,RGBsize;
    
    //pre-set out for 1 value
    out_dim[0]=1;out_dim[1]=1;out_dim[2]=1;
    plhs[0] = mxCreateNumericArray(2, out_dim, mxUINT8_CLASS, mxREAL);
    outMatrix = (unsigned char*)mxGetData(plhs[0]);
    
    //mexAtExit(exit_routine);
    //INPUT MANAGEMENT TODO...
    if( nrhs != 1)
    {
        mexErrMsgTxt("Incorrect number of inputs!\n");
        outMatrix[0]=0;
        return;
    }
    if(!mxIsChar(prhs[0]))
    {
        mexErrMsgTxt("Invalid input!.");
        outMatrix[0]=0;
        return;
    }
    
    
    
    //GET INPUT
    n_str = (int)mxGetN(prhs[0]);
    in_str = (char*)mxCalloc(n_str+1,sizeof(char));
    mxGetString(prhs[0],in_str,n_str+1);
    
    if(strcmp(in_str,"open")==0)
    {
        g_hInstModule = (HINSTANCE*)mxMalloc(sizeof(HINSTANCE));
        ulSrcID = (ULONG*)mxMalloc(sizeof(ULONG));
        
        //MODULE INITIALIZATION
        ok=init_module();if(!ok){outMatrix[0]=0;mxFree(in_str);mxFree(ulSrcID);mxFree(g_hInstModule);return;}
        ok=init_camera();if(!ok){close_module();outMatrix[0]=0;mxFree(in_str);return;}
        mexPrintf("D850 camera opened!\n");
        outMatrix[0]=1;
        isCameraOpen = true;
    }
    else if(strcmp(in_str,"close")==0)
    { //WARNING: if it's already closed, MATLAB will crash!
        if(isCameraOpen)
        {
            close_camera();
            close_module();
            outMatrix[0]=1;
            isCameraOpen = false;
        }
        else
        {
            mexPrintf("Camera already closed!\n");
            outMatrix[0]=1;
        }
    }
    else if(strcmp(in_str,"live_on")==0)
    {
        if(isCameraOpen)
        {
            //mexPrintf("Camera ID: %d\n",ulSrcID[0]);
            pRefSrc1 = GetRefChildPtr_ID( pRefMod1,ulSrcID[0]);
            if(SetLiveView_status(1))outMatrix[0]=1;
            else outMatrix[0]=0;
        }
        else
        {
            mexErrMsgTxt("Camera not opened!");
            outMatrix[0]=0;
        }
    }
    else if(strcmp(in_str,"live_off")==0)
    {
        if(isCameraOpen)
        {
            pRefSrc1 = GetRefChildPtr_ID( pRefMod1,ulSrcID[0]);
            if(SetLiveView_status(0))outMatrix[0]=1;
            else outMatrix[0]=0;
        }
        else
        {
            mexErrMsgTxt("Camera not opened!");
            outMatrix[0]=0;
        }
    }
    else if(strcmp(in_str,"live_get")==0)
    {
        if(isCameraOpen)
        {
            pRefSrc1 = GetRefChildPtr_ID( pRefMod1,ulSrcID[0]);
            RGBimage = GetLiveViewImage(out_dim);
            //OUTPUT SETUP
            mxDestroyArray(plhs[0]);
            plhs[0] = mxCreateNumericArray(3, out_dim, mxUINT8_CLASS, mxREAL);
            outMatrix = (unsigned char*)mxGetData(plhs[0]);
            RGBsize = out_dim[0]*out_dim[1];
            //mexPrintf("RGB array bytes: %d\n",(RGBsize*3));
            k=0;
            for(j=0;j<out_dim[0];j++)
            {
                for(i=0;i<out_dim[1];i++)
                {
                    outMatrix[j+i*out_dim[0]]=RGBimage[k];//R
                    outMatrix[j+(i*out_dim[0])+RGBsize]=RGBimage[k+1];//G
                    outMatrix[j+(i*out_dim[0])+(RGBsize*2)]=RGBimage[k+2];//B
                    k+=3;
                }
                //mexPrintf("Index: %d\n",j);
            }
            mxFree(RGBimage);
        }
        else
        {
            mexErrMsgTxt("Camera not opened!");
            outMatrix[0]=0;
        }
    } else if(strcmp(in_str,"capture")==0)
    {
        if(isCameraOpen)
        {
            set_saveonDRAM();
            //set_compression_level(5); //Fine JPEG format
            capture();
            if(get_image()) outMatrix[0]=1;
            else outMatrix[0]=0;
        }
        else
        {
            mexErrMsgTxt("Camera not opened!");
            outMatrix[0]=0;
        }
    }
    mxFree(in_str);
    return;
    
}

//******************** AUX FUNCTIONS **************************************
BOOL init_module()
{
    char ModulePath[MAX_PATH];  
    ULONG	ulModID = 0;
    BOOL	bRet;
    
    bRet = Search_Module(ModulePath);
    if ( bRet == false ) 
    {
		mexPrintf( "\"Type0022 Module\" is not found.\n" );
		return false;
	}
    
    bRet = Load_Module(ModulePath);
    if ( bRet == false ) 
    {
		mexPrintf( "Failed in loading \"Type0022 Module\".\n" );
		return false;
	}
    mexMakeMemoryPersistent(g_hInstModule);
    // Allocate memory for reference to Module object.
	pRefMod1 = (LPRefObj)mxMalloc(sizeof(RefObj));
	if ( pRefMod1 == NULL ) {
		mexPrintf( "There is not enough memory.\n" );
		return false;
	}
    
	InitRefObj(pRefMod1);
    
    //mexPrintf("64-bit Type0022 module loaded succesfully!\n");
    //---------------------------------------------------------------------
    
    // Allocate memory for Module object.
	pRefMod1->pObject = (LPNkMAIDObject)malloc(sizeof(NkMAIDObject));
	if ( pRefMod1->pObject == NULL ) {
		mexPrintf( "There is not enough memory." );
		if ( pRefMod1 != NULL )	mxFree( pRefMod1 );
		return false;
	}

	//	Open Module object
	pRefMod1->pObject->refClient = (NKREF)pRefMod1;
	bRet = Command_Open(NULL,					// When Module_Object will be opend, "pParentObj" is "NULL".
								pRefMod1->pObject,	// Pointer to Module_Object 
								ulModID );			// Module object ID set by Client
	if ( bRet == false ) {
		mexPrintf( "Module object can't be opened.\n" );
		if (pRefMod1->pObject != NULL)	free( pRefMod1->pObject );
		if (pRefMod1 != NULL)	mxFree( pRefMod1 );
		return false;
	}

	//	Enumerate Capabilities that the Module has.
	bRet = EnumCapabilities( pRefMod1->pObject, &(pRefMod1->ulCapCount), &(pRefMod1->pCapArray), NULL, NULL );
	if ( bRet == false ) {
		mexPrintf( "Failed in enumeration of capabilities." );
		if ( pRefMod1->pObject != NULL )	free( pRefMod1->pObject );
		if ( pRefMod1 != NULL )	mxFree( pRefMod1 );
		return false;
	}

	//	Set the callback functions(ProgressProc, EventProc and UIRequestProc).
	bRet = SetProc( pRefMod1 );
	if ( bRet == false ) {
		mexPrintf( "Failed in setting a call back function." );
		if ( pRefMod1->pObject != NULL )	free( pRefMod1->pObject );
		if ( pRefMod1 != NULL )	mxFree( pRefMod1 );
		return false;
	}

	//	Set the kNkMAIDCapability_ModuleMode.
	if( CheckCapabilityOperation( pRefMod1, kNkMAIDCapability_ModuleMode, kNkMAIDCapOperation_Set )  ){
		bRet = Command_CapSet( pRefMod1->pObject, kNkMAIDCapability_ModuleMode, kNkMAIDDataType_Unsigned, 
										(NKPARAM)kNkMAIDModuleMode_Controller, NULL, NULL);
		if ( bRet == false ) {
			mexPrintf( "Failed in setting kNkMAIDCapability_ModuleMode." );
			return false;
		}
	}
    mexMakeMemoryPersistent(pRefMod1);
    return true;
}

BOOL close_module()
{
    BOOL	bRet;
    bRet = Close_Module(pRefMod1);
	if (bRet == false) mexPrintf( "Module object cannot be closed.\n" );
    
    FreeLibrary(*g_hInstModule);
    mxFree(g_hInstModule);
	//g_hInstModule = NULL;
    
    // Free memory blocks allocated in this function.
	if(pRefMod1->pObject != NULL) free( pRefMod1->pObject );
	if(pRefMod1 != NULL)	mxFree( pRefMod1 );
    //mexPrintf("Module cleared.\n");
    return true;
}

BOOL init_camera()
{
    BOOL	bRet;
	NkMAIDEnum	stEnum;

	LPNkMAIDCapInfo pCapInfo = GetCapInfo( pRefMod1, kNkMAIDCapability_Children );
	if ( pCapInfo == NULL ) return false;
 
	// check data type of the capability
	if ( pCapInfo->ulType != kNkMAIDCapType_Enum ) return false;
	// check if this capability supports CapGet operation.
	if ( !CheckCapabilityOperation( pRefMod1, kNkMAIDCapability_Children, kNkMAIDCapOperation_Get ) ) return false;

	bRet = Command_CapGet( pRefMod1->pObject, kNkMAIDCapability_Children, kNkMAIDDataType_EnumPtr, (NKPARAM)&stEnum, NULL, NULL );
	if( bRet == false ) return false;

	// check the data of the capability.
	if ( stEnum.wPhysicalBytes != 4 ) return false;
    if ( stEnum.ulElements == 0 ) {
		mexPrintf("There is no Camera objects.\n");
		return false;
	}
    
    // allocate memory for array data
	stEnum.pData = malloc( stEnum.ulElements * stEnum.wPhysicalBytes );
	if ( stEnum.pData == NULL ) return false;
	// get array data
	bRet = Command_CapGetArray( pRefMod1->pObject, kNkMAIDCapability_Children, kNkMAIDDataType_EnumPtr, (NKPARAM)&stEnum, NULL, NULL );
	if( bRet == false ) {
		free( stEnum.pData );
		return false;
	}
    
	*ulSrcID = ((ULONG*)stEnum.pData)[0];
	free( stEnum.pData );
    //mexPrintf("Camera ID: %d\n",ulSrcID);
    pRefSrc1 = GetRefChildPtr_ID( pRefMod1, *ulSrcID );
	if ( pRefSrc1 == NULL ) {
		// Create Source object and RefSrc structure.
		if ( AddChild( pRefMod1, *ulSrcID ) == TRUE ) {
			//printf("Camera object is opened.\n");
		} else {
			printf("Camera object can't be opened.\n");
			return false;
		}
		pRefSrc1 = GetRefChildPtr_ID( pRefMod1, *ulSrcID );
	}
    // Get CameraType
	Command_CapGet( pRefSrc1->pObject, kNkMAIDCapability_CameraType, kNkMAIDDataType_UnsignedPtr, (NKPARAM)&g_ulCameraType, NULL, NULL );
    mexMakeMemoryPersistent(ulSrcID);
}

BOOL close_camera()
{
    BOOL ok;
    //mexPrintf("Camera closed.\n");
    ok = RemoveChild(pRefMod1,*ulSrcID);
    mxFree(ulSrcID);
    mexPrintf("D850 camera closed.\n");
    return ok;
}

BOOL set_saveonDRAM()
{
    ULONG ulValue = 1;
    return Command_CapSet( pRefSrc1->pObject, kNkMAIDCapability_SaveMedia, kNkMAIDDataType_Unsigned, (NKPARAM)ulValue, NULL, NULL );
}

BOOL set_compression_level(ULONG lev)
{
    return Command_CapSet( pRefSrc1->pObject, kNkMAIDCapability_CompressionLevel, kNkMAIDDataType_Unsigned, (NKPARAM)(lev-1), NULL, NULL );
}

BOOL capture()
{
    LPNkMAIDObject pSourceObject = pRefSrc1->pObject;
	ULONG	ulCount = 0L;
	BOOL bRet;
	LPRefCompletionProc pRefCompletion;
	pRefCompletion = (LPRefCompletionProc)malloc(sizeof(RefCompletionProc));
	pRefCompletion->pulCount = &ulCount;
	pRefCompletion->pRef = NULL;

	// Start the process
	bRet = Command_CapStart( pSourceObject, kNkMAIDCapability_Capture, (LPNKFUNC)CompletionProc, (NKREF)pRefCompletion, NULL );
	if ( bRet == false ) return false;
	// Wait for end of the process and issue Command_Async. not working?
    //mexPrintf("ulcount: %d\n",ulCount);
	IdleLoop( pSourceObject, &ulCount, 1 );

    //Command_Async - Not sure why here
    CallMAIDEntryPoint( pSourceObject,
						kNkMAIDCommand_Async,
						0,
						kNkMAIDDataType_Null,
						(NKPARAM)NULL,
						(LPNKFUNC)NULL,
						(NKREF)NULL );
	return true;
}

BOOL get_image()
{
    BOOL	bRet;
	NkMAIDEnum	stEnum;
	UWORD	nloop = 0;
	ULONG	pulItemID;
    LPRefObj	pRefItm = NULL;
    LPRefObj	pRefDat = NULL;
    
    while(stEnum.ulElements == 0 || nloop<10)
    {
        bRet = Command_CapGet( pRefSrc1->pObject, kNkMAIDCapability_Children, kNkMAIDDataType_EnumPtr, (NKPARAM)&stEnum, NULL, NULL );
        if( bRet == false ) return false;
        Sleep(5);nloop++;
    }
    // check the data of the capability.
	if ( stEnum.wPhysicalBytes != 4 ) return false;

	// allocate memory for array data
	stEnum.pData = malloc( stEnum.ulElements*stEnum.wPhysicalBytes);
	if ( stEnum.pData == NULL ) return false;
	// get array data
	bRet = Command_CapGetArray(pRefSrc1->pObject, kNkMAIDCapability_Children, kNkMAIDDataType_EnumPtr, (NKPARAM)&stEnum, NULL, NULL );
	if( bRet == false ) {
		free( stEnum.pData );
		return false;
	}
    //Get image ID
    pulItemID = ((ULONG*)stEnum.pData)[0];
    free(stEnum.pData );
    
    //Create Children object for image object
    pRefItm = GetRefChildPtr_ID(pRefSrc1, pulItemID);
	if ( pRefItm == NULL ) {
		// Create Item object and RefSrc structure.
		if ( AddChild( pRefSrc1, pulItemID ) == TRUE ) {
			mexPrintf("Item object is opened.\n");
		} else {
			mexPrintf("Item object can't be opened.\n");
			return false;
		}
		pRefItm = GetRefChildPtr_ID( pRefSrc1, pulItemID );
	}
    
    //reset if file removed flag
    g_bFileRemoved = false;
    
    //Create children object for image data
    pRefDat = GetRefChildPtr_ID( pRefItm, kNkMAIDDataObjType_Image );
	if ( pRefDat == NULL ) {
		// Create Image object and RefSrc structure.
		if ( AddChild( pRefItm, kNkMAIDDataObjType_Image ) == TRUE ) {
			mexPrintf("Image data is opened.\n");
		} else {
			mexPrintf("Image data can't be opened.\n");
			return false;
		}
		pRefDat = GetRefChildPtr_ID( pRefItm, kNkMAIDDataObjType_Image );
	}
    
    //Acquire image data
    IssueAcquire(pRefDat);
    bRet = RemoveChild( pRefItm, kNkMAIDDataObjType_Image );
    bRet = RemoveChild( pRefSrc1,pulItemID); //Remove image object from camera
    return true;
}

BOOL SetLiveView_status(ULONG st) //0-OFF, 1-ON
{
    return Command_CapSet( pRefSrc1->pObject,kNkMAIDCapability_LiveViewStatus, kNkMAIDDataType_Unsigned, (NKPARAM)st, NULL, NULL );
}

unsigned char* GetLiveViewImage(mwSize* dim)
{
	ULONG	ulHeaderSize = 0;		//The header size of LiveView
    ULONG	JPEGDataSize = 0;
	NkMAIDArray	stArray;
	int i = 0;
	unsigned char* pucData = NULL;	// LiveView data pointer
    unsigned char* jpegData = NULL;
    unsigned char* rgbData = NULL;
    ULONG   RGBDataSize = 0;
	BOOL	bRet = true;

    //JPEGLIB---------------------------
    struct jpeg_decompress_struct cinfo;
	struct my_error_mgr jerr;
    int row_stride, width, height, pixel_size, rc;
    //----------------------------------

	// Set header size of LiveView
	if (g_ulCameraType == kNkMAIDCameraType_D850)
	{
		ulHeaderSize = 384;
	}

	memset( &stArray, 0, sizeof(NkMAIDArray) );		
	
	bRet = GetArrayCapability( pRefSrc1, kNkMAIDCapability_GetLiveViewImage, &stArray );
	if ( bRet == false ) return false;
				
	
	// Get data pointer to JPEG Data
	pucData = (unsigned char*)stArray.pData;
    pucData = pucData+ulHeaderSize;

    //allocate jpeg data memory and copy
    JPEGDataSize = stArray.ulElements-ulHeaderSize;
    jpegData = (unsigned char*)mxMalloc(JPEGDataSize);
    memcpy(jpegData,pucData,JPEGDataSize);
    
    
    //JPEG DECODER
    cinfo.err = jpeg_std_error(&jerr.pub);
    if (setjmp(jerr.setjmp_buffer)) //Set jump point in case of JPEG error
    {
        jpeg_destroy_decompress(&cinfo);
        free(stArray.pData);
        mxFree(jpegData);
        return NULL;
    }
    
	jpeg_create_decompress(&cinfo);
    jpeg_mem_src(&cinfo, jpegData, JPEGDataSize);
    
    rc = jpeg_read_header(&cinfo, TRUE);
    if (rc != 1) {
        mexPrintf("Not valid JPEG Data!");
        free(stArray.pData);
        mxFree(jpegData);
        return NULL;
    }
    jpeg_start_decompress(&cinfo);
    
    width = cinfo.output_width;
	height = cinfo.output_height;
	pixel_size = cinfo.output_components;
    
    //Allocate RGB out array
    RGBDataSize = width * height * pixel_size;
	rgbData = (unsigned char*) mxMalloc(RGBDataSize);
    row_stride = width * pixel_size;
    
    //Getting RGB Data
    while (cinfo.output_scanline < cinfo.output_height)
    {
		unsigned char *buffer_array[1];
		buffer_array[0] = rgbData + \
						   (cinfo.output_scanline) * row_stride;

		jpeg_read_scanlines(&cinfo, buffer_array, 1);
	}
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    //mexPrintf("IN Width: %d Height: %d\n",width,height);
    dim[1] = (mwSize)width;
    dim[0] = (mwSize)height;
    dim[2] = 3;
    
	free(stArray.pData);
    mxFree(jpegData);
	return rgbData;
}

void exit_routine(void)
{
  //mexPrintf("Closing...\n");
  close_camera();
  close_module();
}

void return_ok(mxArray *pout[] ,unsigned char val)
{
    mwSize outd[3];
    unsigned char *outMatrix;

}