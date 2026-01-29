import Header from './components/Header'
import { CardWrapper } from './components/CardWrapper'
import { Alert, AlertDescription, AlertIcon, AlertTitle, HStack, VStack } from '@chakra-ui/react'
import SendButton from './components/SendButton'
import SelectImage from './components/SelectImage'
import { useEffect, useState } from 'react'
import ResultImage from './components/ResultImage'


export default function App() {
  const [selectedImage, setSelectedImage] = useState<string>("");
  const [processedImage, setProcessedImage] = useState<string>("");
  const [tx, setTx] = useState(0);
  const [isSending, setIsSending] = useState(false);
  const [wsState, setWsState] = useState<"open" | "closed">("closed");
  const [showAlert, setShowAlert] = useState(false);

  useEffect(() => {
    const ws = new WebSocket("ws://127.0.0.1:3010");

    ws.onopen = () => {
      setWsState("open");
    }

    ws.onclose = () => {
      setWsState("closed");
    }

    ws.onerror = () => {
      setWsState("closed");
    }
    // console.log(wsState);

    ws.onmessage = (event) => {
      const msg = event.data;

      if (msg.slice(0, 3) == "TX:") {
        const value = Number(msg.slice(3).trim());
        setTx(isNaN(value) ? 100 : value * 100);
      }
    };
    
    return () => ws.close();
  }, []);

  useEffect(() => {
    if (wsState == "closed") {
      setShowAlert(true);
    } else {
      setShowAlert(false);
    }
  }, [wsState]);



  const handleSend = async() => {
    if (!selectedImage) {
      alert("画像が選択されていません");
      return;
    }

    setIsSending(true);

    try{
    const blob = await fetch(selectedImage).then(r => r.blob());

    const formData = new FormData();
    formData.append("image", blob, "selected.png");

    const res = await fetch("http://localhost:3000/upload", {
      method: "POST",
      body: formData,
    })

    if (!res.ok) {
      console.log("server error");
    }

    const data = await res.json();

    if (!data.image) {
      console.log("image error");
    }

    const outputUrl = `data:image/png;base64,${data.image}`;
    
    setProcessedImage(outputUrl);
  } catch(err) {
    console.error(err);
  } finally {
    setIsSending(false);
  }
  };

  const handleSelectedImage = (image: string) => {
    if (!isSending) {
      setSelectedImage(image);
    }
  };

  return (
    <div>
      {showAlert && (
        <Alert 
          status="error" 
          zIndex={1000} 
          position="fixed"
          top="0"
          left="0"
          right="0"
        >
          <AlertIcon />
          <AlertTitle>接続エラー</AlertTitle>
          <AlertDescription>WebSocket が切断されました</AlertDescription>
        </Alert>
      )}
      <Header/>
      <VStack style={{paddingTop: "80px"}}>
        <HStack alignItems="start" spacing={8} mb="10px">
          <CardWrapper name={"画像の選択"} component={() => (<SelectImage Image={selectedImage} onSelect={handleSelectedImage}/>)}/>
          <CardWrapper name={"表示中の画像"} component={() => (<ResultImage tx={tx} isSending={isSending} Image={processedImage}/>)}/>
        </HStack>
        <HStack>
          <SendButton wsState={wsState} isSending={isSending} onSend={handleSend}/>
        </HStack>
      </VStack>
    </div>
  )
}
