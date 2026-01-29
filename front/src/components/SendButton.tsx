import { Button } from "@chakra-ui/react"


type PropType = {
    wsState: string;
    isSending: boolean;
    onSend: () => void;
}

export default function SendButton({ wsState, isSending, onSend }: PropType) {
    return (
        <Button 
            disabled={(isSending || (wsState=="closed")) ? true : false} 
            onClick={onSend} 
            bg={isSending ? "#666666ff" : "white"} 
            width="100px"
            height="50px"
        >
            送信
        </Button>
    );
}
