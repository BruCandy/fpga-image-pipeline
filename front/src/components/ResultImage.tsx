import { Card, CardBody, CircularProgress, CircularProgressLabel, VStack } from "@chakra-ui/react";


type PropType = {
    tx: number;
    isSending: boolean;
    Image: string;
}
export default function ResultImage ({ tx, isSending, Image }: PropType) {
    return (
        <VStack justifyContent="center" alignItems="center" h="580px">
            {isSending ? <CircularProgress value={tx} max={100}>
                    <CircularProgressLabel>{Math.round(tx)}%</CircularProgressLabel>
                  </CircularProgress>
                   :(Image ? <Card 
                                className='mb-8 flex w-full scroll-mt-20 flex-col shadow-md'
                                w="580px"
                                h="580px"
                            >
                                <CardBody><img src={Image} style={{ width: "580px"}}/></CardBody>
                            </Card> :<Card 
                            className='mb-8 flex w-full scroll-mt-20 flex-col shadow-md'
                            w="580px"
                            h="580px"
                            bg={"gray.100"}
                        >
                            <CardBody
                                display="flex"
                                alignItems="center"
                                justifyContent="center"
                            >
                                <p className="text-4xl font-bold text-gray-400">No Data</p>
                            </CardBody>
                        </Card>)}
        </VStack>
    );
}
